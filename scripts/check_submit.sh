#!/usr/bin/env bash
# 提交规范检查：目录命名（必须英文）+ 示例保留名。
# 说明：本课程允许直接复制示例作为起点，因此不做查重。
# 用法：在仓库根目录执行  bash scripts/check_submit.sh
set -u

EXAMPLE="example-zhangsan"

if [ ! -d submit ]; then
    echo "缺少 submit/ 目录"
    exit 1
fi

overall=0
count=0
for dir in submit/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    count=$((count + 1))
    echo "==> [$name] 提交规范"

    # 1. 目录名必须是英文名：字母、数字、下划线、点、中划线
    case "$name" in
        *[!A-Za-z0-9._-]*)
            echo "  [FAIL] 目录名必须使用英文、数字、下划线或中划线（例如 zhangsan）"
            overall=1
            ;;
        *)
            echo "  [OK]   目录名符合规范"
            ;;
    esac

    # 2. example- 前缀是示例保留名，学员不能用
    case "$name" in
        example-*)
            if [ "$name" != "$EXAMPLE" ]; then
                echo "  [FAIL] example- 前缀是示例保留名，请用你自己的英文名"
                overall=1
            fi
            ;;
    esac
done

echo "----------------------------------------"
if [ "$count" -eq 0 ]; then
    echo "submit/ 下没有找到任何提交目录。"
    exit 1
fi
if [ "$overall" -ne 0 ]; then
    echo "提交规范检查未通过（共检查 $count 个目录），请根据上方提示修改。"
    exit 1
fi
echo "全部提交规范检查通过（共 $count 个目录）。"
