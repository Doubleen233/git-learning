# Git 学习实验：A+B Problem

这是一个用来练习 Git 基本用法的实验仓库。你的任务有三个：

1. 在 `submit/你的英文名/` 目录下完成 `main.cpp`，实现 A+B Problem；
2. 在同一目录下写好你的作业文档 `README.md`；
3. 本地检查通过后发起 Pull Request，并在 PR 评论区回复 `compile`，让 GitHub Actions 检查全部变绿。

> **关于自动检查**：流水线**不会**随 push 自动运行。你在 PR 评论区回复一条包含 `compile`
> 的评论，GitHub Actions 才会编译你的代码、跑测试、检查文档和目录规范，
> 并把结果作为检查状态报到这个 PR 上。

## 题目说明

### A+B Problem

输入两个整数 a 和 b，输出它们的和。

**输入格式**

一行，两个整数 a 和 b，用空格分隔。

**输出格式**

一行，一个整数，表示 a + b。

**数据范围**

-10^9 ≤ a, b ≤ 10^9

**样例**

| 输入 | 输出 |
| --- | --- |
| 3 5 | 8 |

> 提示：a + b 的结果可能超出 32 位 int 的表示范围，想一想该用什么类型。

## 仓库结构

| 路径 | 说明 |
| --- | --- |
| `submit/example-zhangsan/` | 成功示例：可直接复制作为你的起点 |
| `submit/你的英文名/` | 你的提交目录，需要你自己创建，里面有 `main.cpp` 和 `README.md` |
| `tests/` | 测试数据，`1.in` 是输入，`1.out` 是期望输出 |
| `check.sh` | **一键本地检查**，提交前先跑它 |
| `scripts/run_tests.sh` | 编译并测试 `submit/` 下的所有提交 |
| `scripts/check_readme.sh` | 检查 `submit/` 下所有作业文档的规范性 |
| `scripts/check_submit.sh` | 检查目录命名（必须英文） |
| `.github/workflows/ci.yml` | GitHub Actions 配置，评论 `compile` 时运行 |

## 作业流程

### 第 0 步：Fork 仓库

在本仓库页面点击右上角 **Fork** 按钮，把仓库复刻到你自己的账号下。之后你所有的工作都在你的 Fork 里进行，不要直接改动上游仓库。

### 第 1 步：Clone 到本地

```bash
git clone https://github.com/你的用户名/git-learning.git
cd git-learning
```

### 第 2 步：创建分支

```bash
git checkout -b homework/你的英文名
```

### 第 3 步：创建你的提交目录

```bash
mkdir -p submit/你的英文名
```

目录名**必须使用英文**（拼音也可以），只能包含字母、数字、下划线、点、中划线，例如：

- `submit/zhangsan`
- `submit/zhang_san`
- `submit/zhangsan01`

不能用中文目录名，也不能用 `example-` 开头（这是示例保留名）。

在 `submit/你的英文名/` 下需要两个文件：

- `main.cpp` —— 你的 A+B 代码；
- `README.md` —— 你的作业文档，必须包含下面"作业文档要求"里的 5 个章节。

**可以直接复制示例作为起点**（本题的 a+b 不是学习重点，重点是把 Git 流程走通）：

```bash
cp -r submit/example-zhangsan submit/你的英文名
```

复制完要改两处：`## 姓名与学号` 必须换成你自己的信息（检查脚本会检查，仍是示例信息会失败），
`## Git 学习心得` 建议写你真实的操作过程（命令、报错、怎么解决的）。

### 第 4 步：本地自测

在仓库根目录运行一条命令：

```bash
bash check.sh
```

它会依次做三件事：编译并跑测试用例、检查文档章节、检查目录命名。
全部通过后再进行下一步 —— 这等于提前跑一遍 GitHub Actions。

### 第 5 步：提交 commit

```bash
git add submit/你的英文名/
git commit -m "feat: 完成 A+B 代码与作业文档"
```

### 第 6 步：推送、发起 PR、触发检查

```bash
git push origin homework/你的英文名
```

推送后在 GitHub 页面上向**上游仓库的 main 分支**发起 Pull Request，然后在 PR 评论区回复：

```
compile
```

流水线会开始运行，三个检查（编译与测试 / 检查文档规范 / 检查提交规范）会显示在 PR 页面下方。

### 第 7 步：看检查结果、响应 Review

- 检查挂了：点开失败的任务看日志，修好后 `git push`，**再评论一次 `compile`**，不需要重开 PR；
- Review 有意见：按意见修改，继续 push 即可。

## 作业文档要求

你的 `submit/你的英文名/README.md` 必须包含下面 5 个章节（缺一不可，检查脚本会逐项核对）：

| 章节 | 写什么 |
| --- | --- |
| `## 姓名与学号` | 姓名 / 学号 / 班级 |
| `## 题目理解` | 用自己的话描述输入格式、输出格式和需要注意的地方 |
| `## 编译与运行方法` | 你在本地如何编译、如何把测试数据喂给程序 |
| `## 测试结果` | 本地 `bash check.sh` 的结论，以及 Actions 的最终结果 |
| `## Git 学习心得` | 用到了哪些 Git 命令，遇到过什么问题，怎么解决的 |

## 常见问题

**Q：为什么 push 之后没有自动跑检查？**

设计如此：只有 PR 评论里出现 `compile` 才会触发，避免每次 push 都消耗 Actions 额度。
改完代码后重新评论一次 `compile` 即可。

**Q：检查在哪里看？**

PR 页面下方的检查项（Checks），或仓库顶部的 **Actions** 标签页。点进任务可以看完整日志。

**Q：为什么 "Checks" 标签页显示 0，但下方显示 "All checks have passed"？**

因为检查结果是以 **commit status**（提交状态）上报的，而不是 Actions 的 check run。
PR 的 "Checks" 标签页只列出 check run；合并框会同时统计两者，所以显示 3 个通过。
这是刻意设计：`issue_comment` 触发的流水线，其 check run 不被分支保护认可，只有 commit status 可以。

**Q：评论了 `compile` 但检查没出现？**

按顺序检查：① 评论是否发在 **PR** 上（Issue 评论不算）；② 内容是否包含 `compile`；
③ 仓库 **Actions** 里是否有一条 **CI** 运行；④ 运行结束后 PR 页面下方是否出现状态检查。
如果 Actions 里有运行但失败，点开日志看是"获取 PR head SHA"步骤还是检查脚本报错。

**Q：为什么"合并"按钮点不了？**

仓库给 main 开了分支保护：检查必须全部通过、且有人批准后才能合并。先评论 `compile` 让检查跑绿。

**Q：合并时提示冲突怎么办？**

先把上游 main 同步到自己的分支：

```bash
git remote add upstream https://github.com/Doubleen233/git-learning.git  # 只需执行一次
git fetch upstream
git rebase upstream/main
```

如果有冲突，按提示打开文件解决，然后：

```bash
git add .
git rebase --continue
```

**Q：可以复制示例吗？**

可以。示例就是给你当起点的，整份复制没问题——本题的 a+b 不是重点，重点是走通 Git 流程。
但有两件事不能省：目录名要用你自己的英文名，`## 姓名与学号` 要改成你自己的信息（脚本会检查）。
这也是真实项目的常态：用模板起步、把内容改成自己的，是正常做法。
