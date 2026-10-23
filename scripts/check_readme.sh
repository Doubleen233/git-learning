#!/usr/bin/env bash
# 检查 submit/ 下每位同学的作业文档（README.md）是否满足结构规范。
# 用法：在仓库根目录执行  bash scripts/check_readme.sh
set -u

EXAMPLE="example-zhangsan"

if [ ! -d submit ]; then
    echo "缺少 submit/ 目录"
    exit 1
fi

required_sections=(
    "姓名与学号"
    "题目理解"
    "编译与运行方法"
    "测试结果"
    "Git 学习心得"
)

check_one() {
    local FILE="$1"
    local err=0

    echo "==> 检查 $FILE"
    if [ ! -s "$FILE" ]; then
        echo "  [FAIL] 文件不存在或为空"
        return 1
    fi

    echo "-- 检查标题"
    if grep -qE "^#[[:space:]]+[^#]" "$FILE"; then
        echo "  [OK]   有一级标题"
    else
        echo "  [FAIL] 缺少一级标题（# 开头）"
        err=1
    fi

    echo "-- 检查必需章节"
    local sec
    for sec in "${required_sections[@]}"; do
        if grep -qE "^##[[:space:]]+${sec}[[:space:]]*$" "$FILE"; then
            echo "  [OK]   ## $sec"
        else
            echo "  [FAIL] 缺少章节：## $sec"
            err=1
        fi
    done

    echo "-- 检查占位文字是否已全部替换"
    if grep -n "请在此填写" "$FILE" > /dev/null; then
        grep -n "请在此填写" "$FILE" | cut -d: -f1 | while IFS= read -r lineno; do
            echo "  [FAIL] 第 ${lineno} 行仍是占位文字"
        done
        err=1
    else
        echo "  [OK]   没有残留的占位文字"
    fi

    # 允许复制示例，但个人信息必须改成自己的（示例目录本身跳过）
    if [ "$(basename "$(dirname "$FILE")")" != "$EXAMPLE" ]; then
        echo "-- 检查个人信息"
        local info
        info=$(awk '/^##[[:space:]]+姓名与学号/{f=1; next} f && /^##[[:space:]]/{f=0} f' "$FILE")
        if [ -z "$(printf '%s' "$info" | tr -d '[:space:]')" ]; then
            echo "  [FAIL] \"姓名与学号\" 章节没有内容"
            err=1
        elif printf '%s' "$info" | grep -q "示例"; then
            echo "  [FAIL] \"姓名与学号\" 还是示例信息，请改成你自己的姓名/学号/班级"
            err=1
        else
            echo "  [OK]   个人信息已填写"
        fi
    fi

    return $err
}

overall=0
count=0
for dir in submit/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    count=$((count + 1))
    if ! check_one "${dir}README.md"; then
        overall=1
    fi
done

echo "----------------------------------------"
if [ "$count" -eq 0 ]; then
    echo "submit/ 下没有找到任何提交目录。"
    exit 1
fi
if [ "$overall" -ne 0 ]; then
    echo "文档检查未通过（共检查 $count 个目录），请按上方提示修改后重新提交。"
    exit 1
fi
echo "全部作业文档检查通过（共 $count 个目录）。"
