# 维护者说明（GitHub 版）

这是 GitCode 版的 GitHub 移植版本：检查脚本完全复用，CI 改成了 GitHub Actions。

## 这套机制是怎么工作的（两个 workflow）

| 文件 | 触发 | 做什么 |
| --- | --- | --- |
| `.github/workflows/compile-trigger.yml` | `issue_comment` | 评论在 PR 上且内容含 `compile` → 给 PR 打上 `compile` 标签（先移除再添加，保证每次评论都能重新触发） |
| `.github/workflows/ci.yml` | `pull_request: labeled`（且标签是 `compile`） | 三个并行任务：编译与测试 / 检查文档规范 / 检查提交规范，检出 PR 的 head commit |

**为什么拆成两个**：GitHub 官方规定，只有 `push`、`pull_request`、`pull_request_target`
触发的检查项才能作为分支保护的"必需检查"；`issue_comment` 触发的检查既不会显示在 PR 上，
也不能满足门禁。所以必须"评论 → 打标签 → 标签触发 PR 检查"。

## 开课前需要做的事

1. **确认 Actions 可用**：Settings → Actions → General，允许 Actions 运行（公开仓库默认开启）。
2. **先跑一次，让检查出现在分支保护列表里**：
   - 开一个测试 PR（任意小改动）；
   - 在 PR 评论区回复 `compile`；
   - 等 Actions 里两条运行完成：`Compile Trigger`（打标签）→ `CI`（三个检查）。
   > GitHub 的分支保护页面只列出**最近一周内实际运行过**的检查项，没跑过就是空的。
3. **给 main 开分支保护**：Settings → Branches → Add branch protection rule：
   - Branch name pattern：`main`
   - ✅ Require a pull request before merging（1 approval）
   - ✅ Require status checks to pass before merging → 搜索并选中
     `编译与测试`、`检查文档规范`、`检查提交规范`
   - 建议 ✅ Do not allow bypassing the above settings
4. **再验证一次**：新建 PR，不评论 → 合并按钮不可用；评论 `compile` → 三个检查通过 → 可合并。

> **单人仓库的限制**：GitHub 不允许自己批准自己的 PR（GitCode 也要求审查人和评审人不同）。
> 学员的 PR 不受影响（作者是学员，批准的是助教）；但**维护者自己的 PR** 会卡住。
> 处理办法二选一：
> 1. 加一个助教账号作为协作者，日常由它批维护类 PR（推荐，长期方案）；
> 2. 维护类 PR 临时把 `Require approvals` 调成 0，合并完再改回来。
>
> 这也意味着：本仓库第一次合并 CI 配置时，需要先临时关掉审批要求（或让第二个账号批准）。

> 注意：`compile-trigger.yml` 由 `issue_comment` 触发，使用的永远是**默认分支 main 上的版本**，
> 所以修改它必须先合入 main 才生效。

## 常见问题排查

| 现象 | 原因 / 处理 |
| --- | --- |
| 评论 `compile` 后什么都没发生 | 评论是否在 **PR** 上；内容是否含 `compile`；`compile-trigger.yml` 是否已在 main 上 |
| 有 `Compile Trigger` 运行但没有 `CI` 运行 | 标签没打上：看 `Compile Trigger` 日志；确认 workflow 有 `issues: write` 权限；PR 右上角是否有 `compile` 标签 |
| 有 `CI` 运行但 job 全 skipped | `labeled` 事件的标签名不是 `compile`（比如手动加了别的标签） |
| 检查出现在旧 commit 上 | 正常：push 新提交后旧检查不满足"最新 commit"要求，**再评论一次 `compile`** 即可重新触发 |
| 分支保护页面搜不到检查 | 还没跑过；先按"开课前第 2 步"跑一次 |
| 合并按钮一直灰 | 检查未全绿，或没有 approval |

## 安全注意

- `ci.yml` 使用 **只读 Token**（`contents: read`），没有任何 secrets —— 跑的是学员代码，必须保持这样。
- `pull_request` 事件执行的是 **PR 分支里的 workflow 文件**，理论上学员可以改它。防线：
  - 分支保护要求这三个检查名，删掉 workflow 会导致检查永不出现 → 合不进去；
  - 把 job 改成"假通过"是可能的，所以 **Review 时留意 diff 里有没有动 `.github/`**；
  - 需要更强保证时可改用 `pull_request_target`（从 main 取 workflow 文件），但必须保持只读权限、不注入 secrets。
- 学员 Fork 的 PR 也能触发（任何人的评论都可以），这正是"自助验收"的设计。

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
                                               └─ 自动打 compile 标签 → CI 三个检查
                                                    └─ Review → 合并
```
