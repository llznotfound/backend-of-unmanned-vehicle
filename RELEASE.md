# Release 0.9.3alpha

## ADD

* 添加warehouse相关的存活检测及状态更新

##FIXED

* 修复fog:heartbeat任务与服务端生产环境配置兼容性不好的问题

# Release 0.9.2alpha

## FIXED

* 修复没有production key的问题

# Release 0.9.1alpha

* 主要是hotfix掉puma的一些配置

## UPDATED

* puma的监听端口修改为8484
* 将puma改为clustered mode

# Release 0.9.0alpha

这是空工程建立之后的第一次发布

## ADD

* 添加两个接口用于雾计算的节点存活检测
* 添加用于雾计算的心跳任务
