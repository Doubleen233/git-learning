# 维护者说明（GitHub 版）

这是 GitCode 版的 GitHub 移植版本：脚本完全复用，只把 CI 换成了 GitHub Actions。

## 这套机制是怎么工作的

- **触发**：`issue_comment`（评论创建时），条件是该评论在 **PR** 上、且内容包含 `compile`；
- **检出**：显式 `checkout refs/pull/<PR号>/head`，所以跑的一定是 PR 分支的代码，不是 main；
- **三个并行任务**：编译与测试 / 检查文档规范 / 检查提交规范，各自独立显示在 PR 的 Checks 里；
- **权限**：`contents: read`，只读 Token，没有任何 secrets；
- **额度**：公开仓库的标准 runner 免费且不限分钟。

> 注意：`issue_comment` 触发的 workflow 取自**默认分支（main）上的文件**。
> 修改 `.github/workflows/ci.yml` 后，要先合入 main 才会对新评论生效。

## 开课前需要做的事

1. **确认 Actions 可用**：Settings → Actions → General，允许 Actions 运行（公开仓库默认开启）。
2. **给 main 开分支保护**：Settings → Branches → Add branch protection rule：
   - Branch name pattern：`main`
   - 勾选 **Require a pull request before merging**（至少 1 个 approval）
   - 勾选 **Require status checks to pass before merging**，添加这三个检查：
     `编译与测试`、`检查文档规范`、`检查提交规范`
   - 建议勾选 **Do not allow bypassing the above settings**
3. **验证一次完整流程**：自己新开一个测试 PR，评论 `compile`，确认三个检查出现并通过。
4. 确认自带示例 `submit/example-zhangsan/` 在 Actions 里是绿的。

## 为什么要评论触发

- 控制 Actions 消耗和通知噪音：只有真正要验收时才跑；
- 学员改完代码后重新评论 `compile` 即可重跑，不需要重开 PR。

如果以后想改回 push/PR 自动触发，把 `on:` 改成：

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

并把各 job 的 `if` 条件删掉、`refs/pull/...` 的检出改回默认即可。

## 常见问题排查

| 现象 | 原因 / 处理 |
| --- | --- |
| 评论 `compile` 后没有任何运行 | 评论是否发在 **PR** 上（Issue 评论不算）；内容是否包含 `compile`；`ci.yml` 是否已在 main 上 |
| Actions 里有运行但所有 job 显示 skipped | `if` 条件不满足：不是 PR 评论，或评论内容不含 `compile` |
| 检查一直"等待/未出现" | 分支保护里要求的检查名与实际 job 名不一致 |
| 日志里 `submit/` 没有学员目录 | 不该出现；检出用的是 `refs/pull/<N>/head`，如出现请看"打印检出版本"步骤的 `git log` |
| 合并按钮不可点 | 分支保护要求检查通过 + 1 个 approval，先评论 `compile` 跑绿 |

## 安全注意

- 跑的是**不可信的 PR 代码**，所以 Token 必须保持只读（`contents: read`），
  **绝对不要**在 workflow 里加 secrets 或提高权限；
- 学员 Fork 的 PR 也能触发（评论由任何人发出即可），这正是我们要的"自助验收"；
- 如果担心滥用，可以在 `if` 里加评论者权限判断（如 `github.event.comment.author_association == 'OWNER'`）。

## 如何新增测试用例 / 调整检查

- 新增用例：在 `tests/` 下加 `N.in` / `N.out`，脚本自动遍历，无需改 CI；
- 文档检查：`scripts/check_readme.sh` 的 `required_sections` 与占位文字标记；
- 目录命名：`scripts/check_submit.sh` 的 `EXAMPLE` 变量（示例目录名）；
- 改完先本地 `bash check.sh` 跑一遍，再按"开课前"的验证流程确认一次。

## 学员提交流程一览（讲解时可直接投屏）

```
Fork 仓库
  └─ git clone（自己的 Fork）
       └─ git checkout -b homework/英文名
            └─ cp -r submit/example-zhangsan submit/英文名（或自己写）
                 └─ 改「姓名与学号」和「Git 学习心得」
                      └─ bash check.sh（本地一键自检）
                           └─ git add / git commit
                                └─ git push origin homework/英文名
                                     └─ 发 PR 到上游 main
                                          └─ PR 评论区回复 compile
                                               └─ Actions 自动检查 → Review → 合并
```
