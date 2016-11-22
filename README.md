<a href="https://portal.azure.cn/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fahpeng%2FDockerSwarm%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/ahpeng/DockerSwarm/master/images/azuremooncake.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fahpeng%2FDockerSwarm%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
<a href="https://portal.azure.local/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fahpeng%2FDockerSwarm%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="hhttps://raw.githubusercontent.com/ahpeng/DockerSwarm/master/images/azureStack.png"/>
</a>

# 在Azure中国部署Docker Swarm Cluster

本模板参考Azure Stack Quick Template，源模板链接如下：
https://github.com/Azure/AzureStack-QuickStart-Templates/tree/master/docker-swarm-ubuntu

盆盆对此作了以下四个优化：
1. 修改了Ubuntu的apt源，指向国内的mirror，您可以修改对应的脚本(InstallSwarm.sh)，改为您喜欢的源。
2. 修改docker和docker-compose的安装源，指向daocloud的镜像地址，您可以改为自己的喜欢的镜像地址。
3. 修改docker的mirror hub，指向daocloud的镜像地址。
4. 修改docker swarm的配置，以支持network overlay。

欢迎关注盆盆的微信公众号：sysinternal，欢迎加盆盆为好友哈：markpah   

可以同时在中国区Azure和Azure Stack上部署。由于Ubuntu源指向上海交大服务器，所以建议把资源组设置在中国东部，以便获取更快的速度。或者您可以修改脚本里的源地址。

感谢微软中国Azure架构师Steven Lian和Wei Heng、张磊老师的大力帮助。
