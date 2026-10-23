# A+B Problem 作业（wangxiaoming）

## 姓名与学号
王小明 / 20260007 / 计科 2 班

## 题目理解
输入是一行两个整数 a 和 b，用空格分隔，输出它们的和。
数据范围到 10^9，两个数相加最大约 2×10^9，超过 32 位 int 的上限，所以结果要用 long long 存。

## 编译与运行方法
在仓库根目录执行：

    g++ -std=c++17 -O2 submit/wangxiaoming/main.cpp -o aplusb

把测试数据喂给程序：

    ./aplusb < tests/1.in

输出 8，与 tests/1.out 一致。

## 测试结果
本地执行 `bash check.sh`：编译测试、文档检查、提交规范三项全部通过。
在 PR 评论区回复 `compile` 后，GitHub Actions 的三个状态也是绿色。

## Git 学习心得
用到的命令：clone、checkout -b、add、commit、push，最后在网页上发 PR。
第一次 push 时发现分支名写错了，用 `git branch -m` 改回来再推；
评论 `compile` 第一次没有反应，后来发现是本地改的 workflow 还没合到 main，
重新同步之后就正常了。
