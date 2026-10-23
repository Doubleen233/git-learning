#!/usr/bin/env bash
# 遍历 submit/ 下每位同学的目录：编译其 main.cpp，用 tests/ 下的数据验证。
# 用法：在仓库根目录执行  bash scripts/run_tests.sh
set -u

if [ ! -d submit ]; then
    echo "缺少 submit/ 目录，请先创建 submit/你的姓名/main.cpp"
    exit 1
fi

# 统一处理 CRLF 和行尾空白，避免 Windows/Linux 换行差异造成误判
normalize() { sed -e 's/\r$//' -e 's/[[:space:]]*$//'; }

mkdir -p build

overall=0
count=0
for dir in submit/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    count=$((count + 1))
    src="${dir}main.cpp"
    bin="build/${name}"

    echo "==> [$name] 编译 main.cpp"
    if [ ! -f "$src" ]; then
        echo "  [FAIL] 缺少 ${name}/main.cpp"
        overall=1
        continue
    fi
    if ! g++ -std=c++17 -O2 -Wall -Wextra -o "$bin" "$src"; then
        echo "  [FAIL] 编译失败，请检查代码语法"
        overall=1
        continue
    fi

    pass=0
    fail=0
    for infile in tests/*.in; do
        n=$(basename "$infile" .in)
        expected="tests/${n}.out"
        if [ ! -f "$expected" ]; then
            echo "  缺少期望输出文件：$expected"
            exit 1
        fi

        actual=$(timeout 5s "$bin" < "$infile" 2>&1 | normalize)
        want=$(normalize < "$expected")

        if [ "$actual" = "$want" ]; then
            echo "  [PASS] 用例 $n"
            pass=$((pass + 1))
        else
            echo "  [FAIL] 用例 $n"
            echo "    输入:   $(normalize < "$infile" | tr '\n' ' ')"
            echo "    期望:   $(echo "$want" | tr '\n' ' ')"
            echo "    实际:   $(echo "$actual" | tr '\n' ' ')"
            fail=$((fail + 1))
            overall=1
        fi
    done
    echo "  [$name] 小计：通过 $pass，失败 $fail"
done

echo "----------------------------------------"
if [ "$count" -eq 0 ]; then
    echo "submit/ 下没有找到任何提交目录。"
    exit 1
fi
if [ "$overall" -ne 0 ]; then
    echo "存在未通过的提交（共检查 $count 个目录），请根据上方日志修复。"
    exit 1
fi
echo "全部提交测试通过（共 $count 个目录）。"
