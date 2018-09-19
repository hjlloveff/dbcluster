1、先进入zook目录 执行docker-compose up -d
2、再进行solr目录 执行docker-compose up -d

测试：
进入/opt/solr/server/solr/configsets
修改或者新建一个目录
uradar_article

建立一个core
solr create_collection -c uradar_article -d uradar_article -shards 2 -replicationFactor 3 

然后进行测试 查看word 文档。

后期配合RD 用java 测试
