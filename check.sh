#!/usr/bin/env bash
# 一键本地检查：编译测试 + 文档规范 + 提交规范。
# 用法：在仓库根目录执行  bash check.sh
# 三个检查全部通过才会输出"全部检查通过"并以 0 退出。
set -u

failed=0

echo "================ 1/3 编译与测试 ================"
if ! bash scripts/run_tests.sh; then
    failed=1
fi
echo

echo "================ 2/3 文档规范 =================="
if ! bash scripts/check_readme.sh; then
    failed=1
fi
echo

echo "================ 3/3 提交规范 =================="
if ! bash scripts/check_submit.sh; then
    failed=1
fi
echo

if [ "$failed" -ne 0 ]; then
    echo "检查未全部通过，请按上方提示修改后重跑 bash check.sh。"
    exit 1
fi
echo "全部检查通过。可以把这段输出粘贴到 PR 描述里作为自测证据。"
