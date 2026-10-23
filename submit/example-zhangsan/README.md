# A+B Problem 作业（示例：example-zhangsan）

> 本目录是一份**完整示例**：目录命名、代码、文档都符合检查要求，**可以直接复制作为你的起点**。
> 复制后记得把「姓名与学号」改成你自己的信息，「Git 学习心得」建议写你真实的操作过程。
> ⚠️ 请复制到自己的目录再改，不要直接修改本示例目录（它是全班共用的参照）。

## 姓名与学号
张三（示例） / 20260001 / 计科 1 班

## 题目理解
输入是一行两个整数 a 和 b，用空格分隔；输出它们的和，单独占一行。
注意数据范围到 10^9：两个数的和最大是 2×10^9，超过 32 位 int 的上限（约 2.1×10^9），
所以结果要用 long long，否则大数用例会溢出出错。

## 编译与运行方法
在仓库根目录执行：

    g++ -std=c++17 -O2 submit/example-zhangsan/main.cpp -o aplusb

把测试数据喂给程序：

    ./aplusb < tests/1.in

输出 8，与 tests/1.out 一致。Git Bash、Linux、macOS 下都适用。
复制到自己目录后，把命令里的路径换成 `submit/你的英文名/main.cpp` 即可。

## 测试结果
本地执行 `bash check.sh`：编译测试、文档检查、提交规范三项全部通过。
在 PR 评论区回复 `compile` 后，GitHub Actions 的三个检查也都是绿色。

## Git 学习心得
本次作业用到了 clone、checkout -b、add、commit、push 和 Pull Request。
第一次 push 时提示远程分支有新内容，按照提示先
`git pull --rebase origin homework/zhangsan` 再推送就成功了。
通过这次作业理解了"在自己的分支上工作、改完发 PR 让别人 Review"的基本协作流程。
