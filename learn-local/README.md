# Claude Code 项目架构

## 项目概述
这是一个反向工程/反编译的 Anthropic Claude Code CLI 工具，目标是恢复核心功能并精简次要功能。使用 Bun 作为运行时，采用 ESM 模块系统。

## 主要架构层次

### 1. 运行时与构建系统
- **运行时**: Bun (非 Node.js)
- **构建**: `build.ts` 使用 `Bun.build()` 进行代码分割，入口为 `src/entrypoints/cli.tsx`
- **开发模式**: `scripts/dev.ts` 通过 `-d` flag 注入宏定义
- **模块系统**: ESM (`"type": "module"`) + TSX + React JSX 转换

### 2. 入口与引导
- **`src/entrypoints/cli.tsx`**: 真正的入口点，处理多条快速路径（版本、daemon、bridge 等）
- **`src/main.tsx`**: Commander.js CLI 定义，注册大量子命令
- **`src/entrypoints/init.ts`**: 一次性初始化（遥测、配置、信任对话框）

### 3. 核心循环
- **`src/query.ts`**: 主要 API 查询函数，处理流式响应和工具调用
- **`src/QueryEngine.ts`**: 高级协调器，管理对话状态和轮次循环
- **`src/screens/REPL.tsx`**: 交互式 REPL 屏幕（Ink/React 组件）

### 4. API 层
- **`src/services/api/claude.ts`**: 核心 API 客户端，支持多提供商（Anthropic、AWS Bedrock、Google Vertex、Azure）
- 提供商选择在 `src/utils/model/providers.ts` 中配置

### 5. 工具系统
- **`src/Tool.ts`**: 工具接口定义
- **`src/tools.ts`**: 工具注册表
- **`src/tools/<ToolName>/`**: 61 个工具目录（如 BashTool、FileEditTool、AgentTool 等）
- **`src/tools/shared/`**: 工具共享函数

### 6. UI 层（Ink 框架）
- **`src/ink.ts`**: Ink 渲染包装器
- **`src/ink/`**: 自定义 Ink 框架（分叉/内部）
- **`src/components/`**: 170+ 个 React 组件，在终端 Ink 环境中渲染

### 7. 状态管理
- **`src/state/AppState.tsx`**: 中央应用状态类型和上下文提供者
- **`src/state/store.ts`**: Zustand 风格的 store
- **`src/state/selectors.ts`**: 状态选择器
- **`src/bootstrap/state.ts`**: 会话全局状态的模块级单例

### 8. Bridge/远程控制
- **`src/bridge/`**: 远程控制/桥接模式，通过 `BRIDGE_MODE` feature flag 控制
- CLI 快速路径: `claude remote-control` / `claude rc` / `claude bridge`

### 9. Daemon 模式
- **`src/daemon/`**: 长驻 supervisor，通过 `DAEMON` feature flag 控制

### 10. 功能标志系统
- 通过 `import { feature } from 'bun:bundle'` 使用
- 通过环境变量 `FEATURE_<FLAG_NAME>=1` 启用
- Dev 默认启用: `BUDDY`、`TRANSCRIPT_CLASSIFIER`、`BRIDGE_MODE`、`AGENT_TRIGGERS_REMOTE`
- Build 默认启用: `AGENT_TRIGGERS_REMOTE`

这个架构设计注重模块化和功能隔离，通过 feature flags 灵活控制功能启用，适合 CLI 工具的轻量级需求。