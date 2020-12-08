---
title: npm install参数简述
date: 2017-10-25
tags:
- nodejs
- npm
categories:
 - System
---


:::tip npm install 本地安装

1.将安装包放在`./node_modules`下（运行`npm`命令时所在的目录），如果没有`node_modules`目录，会在当前执行`npm`命令的目录下生成`node_modules`目录。 

2.可以通过`require()`来引入本地安装的包。
:::

:::tip `npm install -g`全局安装


(1) 将安装包放在`/usr/local`下或者你`node`的安装目录。 

(2)可以直接在命令行里使用。
:::

:::tip npm install --save

(1)会把`msbuild`包安装到`node_modules`目录中 

(2)会在`package.json`的`dependencies`属性下添加`msbuild`

(3)之后运行`npm install`命令时，会自动安装`msbuild`到`node_modules`目录中 

(4)之后运行`npm install --production`或者注明`NODE_ENV`变量值为`production`时，会自动安装`msbuild`到`node_modules`目录中
:::

:::tip npm install --save-dev

(1)会把`msbuild`包安装到`node_modules`目录中 

(2)会在`package.json`的`devDependencies`属性下添加`msbuild`

(3)之后运行`npm install`命令时，会自动安装`msbuild`到`node_modules`目录中 

(4)之后运行`npm install --production`或者注明`NODE_ENV`变量值为`production`时，不会自动安装`msbuild`到`node_modules`目录中
:::
