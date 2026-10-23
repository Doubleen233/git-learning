# 维护者说明（GitHub 版）

这是 GitCode 版的 GitHub 移植版本：检查脚本完全复用，CI 换成 GitHub Actions。

## 这套机制是怎么工作的

一个 workflow（`.github/workflows/ci.yml`），触发条件是 **PR 评论里出现 `compile`**：

```
评论 compile
  └─ 读取 PR 的 head SHA（gh api）
       └─ checkout 这个 SHA（保证跑的是 PR 代码）
            └─ 三个并行 job 跑脚本
                 └─ 用 Statuses API 把结果写回 PR head commit
                      └─ 分支保护据此判断能否合并
```

### 为什么不用"打标签再触发"

两个坑叠在一起，导致标签方案行不通：

1. **`issue_comment` 触发的检查不被分支保护认可**：GitHub 官方规定，只有
   `push` / `pull_request` / `pull_request_target` 触发的检查才能作为"必需检查"。
2. **`GITHUB_TOKEN` 产生的事件不会触发新 workflow**（防止递归）。
   所以"评论 → 用 token 打标签 → 标签触发 CI"这一步永远不会发生。

现在的做法用 **Statuses API** 直接往 PR 的 head commit 上报状态，
这是分支保护认可的（commit status 与 check run 同等对待）。

## 开课前需要做的事

1. **确认 Actions 可用**：Settings → Actions → General，允许 Actions 运行。
2. **先跑一次，让状态出现在分支保护列表里**：
   - 开一个测试 PR（任意小改动）；
   - 在 PR 评论区回复 `compile`；
   - 等 Actions 里的 **CI** 运行完成，三个 job 都会上报状态。
   > 分支保护页面只列出最近一周内**上报过**的检查名，没跑过就是空的。
3. **给 main 开分支保护**：Settings → Branches → Add branch protection rule：
   - Branch name pattern：`main`
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging → 搜索并选中
     `编译与测试`、`检查文档规范`、`检查提交规范`
   - 建议 ✅ Do not allow bypassing the above settings
4. **验证**：新建 PR，不评论 → 合并按钮不可用；评论 `compile` → 三个状态变绿 → 可合并。

> **单人仓库的限制**：GitHub 不允许自己批准自己的 PR（GitCode 也要求审查人和评审人不同）。
> 学员的 PR 不受影响（作者是学员，批准的是助教）；但**维护者自己的 PR** 会卡住。
> 处理办法二选一：
> 1. 加一个助教账号作为协作者，日常由它批维护类 PR（推荐，长期方案）；
> 2. 维护类 PR 临时把 `Require approvals` 调成 0，合并完再改回来。

> 注意：`issue_comment` 触发的工作流永远使用**默认分支 main 上的版本**，
> 所以修改 `ci.yml` 必须先合入 main 才生效。

## 常见问题排查

| 现象 | 原因 / 处理 |
| --- | --- |
| 评论 `compile` 后没有运行 | 评论是否在 **PR** 上；内容是否含 `compile`；`ci.yml` 是否已在 main 上 |
| 有运行，但 PR 上没有状态 | 看"上报检查状态"步骤的日志：多为 `statuses: write` 权限或 `gh api` 报错 |
| 状态挂在旧 commit 上 | 正常：push 新提交后旧状态不满足"最新 commit"要求，**再评论一次 `compile`** |
| 分支保护页面搜不到检查 | 还没跑过；先按"开课前第 2 步"跑一次 |
| 合并按钮一直灰 | 状态未全绿，或没有 approval |
| `gh api` 报 404 | PR 不是从本仓库分支开的（极少见）；检查 `pulls/<编号>` 是否存在 |

## 安全注意

- `ci.yml` 权限固定为 `contents: read` + `pull-requests: read` + `statuses: write`；
  **没有任何 secrets**，跑的是学员代码，必须保持这样。
- checkout 时设置了 `persist-credentials: false`，避免学员代码从 `.git/config` 读到 token。
- 学员 Fork 的 PR 也能触发（任何人的评论都可以），这正是"自助验收"的设计。
- 如果担心滥用，可以在 `if` 里加评论者权限判断，例如：
  `github.event.comment.author_association == 'OWNER' || github.event.comment.author_association == 'MEMBER'`。

## 额度

公开仓库的标准 runner **免费且不限分钟**，a+b 项目每次 1~2 分钟，完全够用。

## 如何新增测试用例 / 调整检查

- 新增用例：在 `tests/` 下加 `N.in` / `N.out`，脚本自动遍历，无需改 CI；
- 文档检查：`scripts/check_readme.sh` 的 `required_sections` 与占位文字标记（`请在此填写`）；
- 目录命名：`scripts/check_submit.sh` 的 `EXAMPLE` 变量（示例目录名）；
- 改完先本地 `bash check.sh`，再合入 main，最后按"开课前"的流程验证一遍。

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
                                               └─ Actions 跑检查并上报状态
                                                    └─ Review → 合并
```
