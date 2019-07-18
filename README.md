#### 开发环境

---

1. Visual Studio Code [https://code.visualstudio.com/](https://code.visualstudio.com/)

2. Warcraft-vscode vscode插件

3. nodejs+mysql 提供后台服务

4. git

### 本地启动

---

1. 下载地图源码
   
   ```bash
   git clone https://github.com/battleplatform/WarOfPet.git
   git submodule update --init --recursive`
   ```

2. 下载服务器端源码
   
     `git clone https://github.com/battleplatform/battlepet-server.git`

3. 启动服务器端
   
   1. 修改MySQL链接参数 `src\db.ts` 大约第24行开始
   
   2. 启动
      
      ```bash
      cd path/to/server/code
      npm install
      npm run compile
      node dist/index.js
      ```

4. 启动地图
   
   1. 修改HTTP服务器地址 `src\common.lua` 第5行
   
   2. 使用vscode打开地图文件夹
   
   3. 修改Warcraft-vscode插件配置
      
      1. vscode设置中找到 `Warcraft: Game Args`
      
      2. 点击编辑，在settings.json中添加 
         
         `"warcraft.gameArgs": ["-plugin", "dz_w3_plugin插件路径"]`
   
   4. 运行命令[Ctrl+Shift+P] Warcraft: Run Map

### 

### HTTP同步接口用法

---

接口原型

```
function GetWebContent takes boolean isPost, string url, string data returns string
    return RequestExtraStringData(53, nil, url, data, isPost, 0, 0, 0)
endfunction
```

例如：

```
call GetWebContent(false, "http://www.baidu.com", nil)
```
