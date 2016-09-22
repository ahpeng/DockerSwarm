<a href="https://portal.azure.cn/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fahpeng%2FDockerSwarm%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fahpeng%2FDockerSwarm%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
# 在Azure中国部署Docker Swarm Cluster (docker 1.11.2)

由于测试时中国区(北部)的Docker Extension的版本比较老，存在一些问题，所以改用纯CustomScriptForLinux脚本扩展安装docker和consual以及Swarm。本模板参考Azure Stack Quick Template。可以同时在中国区Azure和私有云上部署。

如果希望测试Docker Extension，可以选择“azuredeploy-fromDockerExtension.json”这个模板，先用CustomScriptForLinux脚本扩展安装docker，再利用Docker Extension安装consual以及Swarm，有一些bug，例如GFW和本身的bug，导致compose报"text file busy"错误。

如果希望测试Docker Extension，也可以先创建预装docker并pull好consual以及Swarm，再运行“dockerswarm-createfromImage.json”这个模板。

https://github.com/Azure/azure-quickstart-templates/tree/master/docker-swarm-cluster

请选择部署在中国北部。

感谢微软中国Azure架构师Steven Lian和Wei Heng、张磊老师的大力帮助。


