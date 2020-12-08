---
title: 树莓派实现ddns
date: 2013-03-06
tags:
- RaspberryPi
categories:
 - RaspberryPi
---




PHP脚本实现DNSPOD动态域名解析 

```bash
<?php
header("Content-type: text/html; charset=utf8");

class Dns
{
#Dnspod账户
private $dnspod_user = 'user@example.com';
#Dnspod密码
private $dnspod_pwd = 'password';
#Dnspod主域名，注意：是你注册的域名
private $domain = 'example.com';
#子域名，如www，如果要使用根域名，用@
private $sub_domain = 'www';

function getMyIp()
{
	try
	{
		$ip = file_get_contents('http://www.leadnt.com/tools/ip.php');
		return $ip;
	}
	catch(Exception $e)
	{
		echo $e->getMessage();
		return null;
	}
}

function api_call($api, $data) 
{
	if ($api == '' || !is_array($data)) {
	exit('内部错误：参数错误');
	}

	$api = 'https://dnsapi.cn/' . $api;
	$data = array_merge($data, array('login_email' => $this->dnspod_user, 'login_password' => $this->dnspod_pwd, 'format' => 'json', 'lang' => 'cn', 'error_on_empty' => 'no'));

	$result = $this->post_data($api, $data);
	if (!$result) {
	exit('内部错误：调用失败');
	}

	$results = @json_decode($result, 1);
	if (!is_array($results)) {
	exit('内部错误：返回错误');
	}

	if ($results['status']['code'] != 1) {
	exit($results['status']['message']);
	}

	return $results;
}

private function post_data($url, $data) 
{
	if ($url == '' || !is_array($data)) {
	return false;
	}

	$ch = @curl_init();
	if (!$ch) {
	exit('内部错误：服务器不支持CURL');
	}

	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
	curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
	curl_setopt($ch, CURLOPT_USERAGENT, 'LocalDomains_PHP/1.0.0(roy@leadnt.com)');
	$result = curl_exec($ch);
	curl_close($ch);

	return $result;
}


public function exec()
{
	$ip = $this->getMyIp();
	$domainInfo = $this->api_call('domain.info',array('domain' => $this->domain));
	$domainId = $domainInfo['domain']['id'];
	$record = $this->api_call('record.list',array('domain_id'=> $domainId,'offset' =>'0','length' => '1','sub_domain' =>$this->sub_domain));
	if($record['info']['record_total'] == 0)
	{
		$this->api_call('record.create',
			array(
				'domain_id' => $domainId,
				'sub_domain' => $this->sub_domain,
				'record_type' => 'A',
				'record_line' => '默认',
				'value' => $ip,
				'ttl' => '3600'
				));
	}
	else
	{
		if($record['records'][0]['value'] != $ip)
		{
			$this->api_call('record.modify',
			array(
				'domain_id' => $domainId,
				'record_id' => $record['records'][0]['id'],
				'sub_domain' => $this->sub_domain,
				'record_type' => 'A',
				'record_line' => '默认',
				'value' => $ip
				));
		}
		else
		{
			echo '指向正常';
		}
	}
}
}
$dns = new Dns();
$dns->exec();
```

``sudo chmod 777 dnspod.php``

加入到定时任务，每个小时执行一次

```bash
vi /etc/crontab

*/55 * * * *  root  /usr/bin/php  /home/pi/dnspod.php  >>  /home/pi/dnspod.log   2>&1
```
    
