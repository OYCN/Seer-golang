# 赛尔号 Go 服务端

赛尔号服务端 Go 语言实现，包含游戏服务器、登录服务器、资源服务器与 GM 管理后台。

## 友情链接

三梦Kose服务端  
链接：<https://github.com/BaiSugar/kose_seer>

## 项目结构

```
d:\go\
├── cmd/
│   └── gameserver/
│       └── main.go              # 主程序入口
├── internal/
│   ├── core/                    # 核心基础设施
│   │   ├── logger/              # 日志
│   │   ├── packet/              # 封包编解码
│   │   ├── protocolvalidator/   # 协议验证
│   │   ├── userdb/              # 用户与游戏数据（JSON / MySQL）
│   │   ├── nonoformcache/       # 超能 NONO 形态缓存
│   │   └── soultransformcache/ # 元神变身缓存
│   ├── game/                    # 游戏逻辑
│   │   ├── battle/              # 战斗系统
│   │   ├── skills/              # 技能与效果
│   │   ├── pets/                # 精灵
│   │   ├── sptboss/             # SPT Boss
│   │   ├── mapogres/            # 地图怪物
│   │   └── typechart/           # 属性克制表
│   ├── handlers/                # 业务处理与 GM API
│   │   ├── handlers.go          # 主处理器（战斗、精灵、地图等）
│   │   ├── gm_handlers.go       # GM HTTP API
│   │   ├── sptboss_gm.go        # SPT Boss GM
│   │   ├── maps_gm.go           # 地图 GM
│   │   ├── dark_portal.go       # 暗黑武斗场
│   │   ├── arena.go             # 竞技场
│   │   ├── gacha.go             # 扭蛋
│   │   ├── task_config.go       # 任务配置
│   │   └── ...
│   └── server/                  # 服务器层
│       ├── gameserver/          # 游戏主服务器（Socket 5000）
│       ├── loginserver/         # 登录服务器（1863）
│       ├── resserver/           # 资源服务器（32400、8088）
│       └── loginip/             # 登录 IP 服务器（32401）
├── GM/                          # GM 网页后台
│   ├── gm_admin.html            # GM 管理主页
│   ├── gm_panel.html            # GM 面板
│   ├── kyse.html                # 前端入口
│   ├── tasks_section.html       # 任务区块
│   └── skills.xml               # 技能配置
├── data/                        # 游戏数据 XML
│   ├── skills.xml               # 技能表
│   ├── spt.xml                  # 精灵表
│   └── items.xml                # 道具表
├── test/                        # 测试数据与编译输出
│   ├── users.json               # 测试用户
│   ├── gm_*.json                # GM 配置文件
│   └── gameserver_*.exe         # 编译产物
├── go.mod
├── 编译.bat                     # 构建入口（调用 compile.ps1）
└── compile.ps1                  # PowerShell 编译脚本
```

## 模块说明

### 服务器层 (`internal/server/`)

| 模块 | 端口 | 说明 |
|------|------|------|
| **gameserver** | 5000 | 游戏主服务器，处理客户端连接与协议 |
| **loginserver** | 1863 | 登录服务器，账号验证与服务器列表 |
| **resserver** | 32400, 8088 | 资源服务器，提供游戏资源与代理 |
| **loginip** | 32401 | 登录 IP 服务器，处理登录 IP 查询 |

### 核心模块 (`internal/core/`)

| 模块 | 说明 |
|------|------|
| **userdb** | 用户与游戏数据，支持 JSON 与 MySQL |
| **packet** | 封包编解码 |
| **logger** | 日志 |
| **protocolvalidator** | 协议验证 |
| **nonoformcache** | 超能 NONO 形态缓存 |
| **soultransformcache** | 元神变身缓存 |

### 游戏逻辑 (`internal/game/`)

| 模块 | 说明 |
|------|------|
| **battle** | 战斗系统 |
| **skills** | 技能与效果 |
| **pets** | 精灵 |
| **sptboss** | SPT Boss |
| **mapogres** | 地图怪物 |
| **typechart** | 属性克制表 |

### 业务处理 (`internal/handlers/`)

处理游戏指令与 GM API，包含：战斗、精灵、地图、暗黑武斗场、竞技场、扭蛋、任务配置、融合规则等。

## 构建与运行

### 编译

Linux：

```bash
chmod +x compile.sh
./compile.sh
./compile.sh --release
./compile.sh --watch
./compile.sh --clean
```

构建产物为 `bin/gameserver`。

Windows：

```powershell
# 普通构建 → test/gameserver_yyyy-MM-dd_HHmm.exe
.\compile.ps1

# Release 构建（-ldflags "-s -w"）
.\compile.ps1 -Release

# 监听变更自动重建
.\compile.ps1 -Watch

# 清理编译产物
.\compile.ps1 -Clean
```

或使用 `编译.bat` 进行构建。

### 运行

运行编译后的 `test/gameserver_*.exe`，或：

```bash
go run ./cmd/gameserver
```

**启动参数：**
- `-y`：跳过免责声明确认，直接启动
- `-import-data-docs`：仅将 data/*.xml 导入 data_docs 表后退出

### 环境变量（MySQL）

| 变量 | 说明 |
|------|------|
| MYSQL_HOST | 主机（默认 127.0.0.1） |
| MYSQL_PORT | 端口（默认 3306） |
| MYSQL_DATABASE | 数据库名（默认 seer） |
<<<<<<< HEAD
| MYSQL_USER | 用户名 |(默认seer）
| MYSQL_PASSWORD | 密码 |（默认abc.123)
=======
| MYSQL_USER | 用户名 |
| MYSQL_PASSWORD | 密码 |
>>>>>>> e4635df (docs: README 改为简体中文)

## 启动流程

1. 显示免责声明并设置对外 IP
2. 设置资源目录（可下载 gameres.rar 或手动指定）
3. 连接 MySQL
4. 启动各服务器：
   - 游戏服务器（5000）
   - 资源服务器（32400、8088）
   - 登录服务器（1863）
   - 登录 IP 服务器（32401）
   - GM 管理（HTTP 8080）

## 依赖

- Go 1.20+
- [github.com/go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)

## 授权

本项目仅供学习研究使用。
