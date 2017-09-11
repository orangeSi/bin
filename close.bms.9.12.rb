#!//ifshk4/BC_PUB/biosoft/PIPE_RD/Package/Ruby/install/bin/ruby -W0
usage="close you subcode project normal yet,
usage:
	all	<subcode> 
		<bigcode> 
		<project_start_date:format example 2016-08-21> 
		<share backup dir> 
		<project path> 
		<zhi kong dir> 
		<sample number> 
		<your chinese name> 
		<workid:ex:BGI0001>  
		<user> 
		<password of bms>

below canot used yet!
	jobtime 
	fillpath
	request
	check
	"

require 'net/http'
require 'pp'


if ARGV[0] == 'all' && ARGV.length ==12
	subcode=ARGV[1]
	bigcode=ARGV[2]
	project_start_date=ARGV[3]
	share_dir=ARGV[4]
	project_path=ARGV[5]
	zhikong_dir=ARGV[6]
	sample_num=ARGV[7]
	name=ARGV[8]
	workid=ARGV[9]
	user=ARGV[10]
	passwd=ARGV[11]
else
	puts usage
	exit
end
#workid='BGI7308'
#subcode='PENztuD'
#bigcode='F16FTSNCKF0718-01'
#project_path='/ifshk7/BC_RD/USER/MICRO_GENOMICS/sikaiwei/F16FTSNCKF0718-01/genome_fragments/seqs/genome'

#project_start_date='2016-08-21'
#share_dir="/ifshk7/BC_RD/USER/MICRO_GENOMICS/sikaiwei/F16FTSNCKF0718-01/"
share_uncomplete_reason=''
#zhikong_dir="/ifshk7/BC_RD/USER/MICRO_GENOMICS/sikaiwei/F16FTSNCKF0718-01/"
zhikong_uncomplete_reason=''
#sample_num='1'
close_stat='正常结题'
print "name is "+name
#name=name.force_encoding("UTF-8")

#name='司凯威'

Ip='192.168.224.57'
Http = Net::HTTP.new(Ip,80)
#path = '/newbms/login/chklogin.jsp'
Agent='Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'
ContentType='application/x-www-form-urlencoded; charset=UTF-8'

def get_taskid(target,data,referer,cookie)
	headers = {
		'Accept'=>'*/*',
		'Accept-Encoding'=>'gzip, deflate',
		'Accept-Language'=>'zh-CN,zh;q=0.8,en;q=0.6',
		'Connection'=>'keep-alive',
		'Content-Length'=>'68',
		'Content-Type'=>'application/x-www-form-urlencoded; charset=UTF-8',
		'Cookie' => cookie,
		'Referer' => 'http://'+Ip+referer,
		'Host'=>'bms.bgitechsolutions.cn',
		'Origin'=>'http://'+Ip,
		'User-Agent'=>Agent,
		'X-Requested-With'=>'XMLHttpRequest'

	}
	response = Http.post(target,data,headers)
	if(response.code == '200' || response.code == '302')
		return response
	else
		print "code is "+response.code
		exit
		return "error"

	end

end

def add_project_path(target,data,referer,cookie)
	headers = {
		'Accept'=>'*/*',
		'Accept-Encoding'=>'gzip, deflate',
		'Accept-Language'=>'zh-CN,zh;q=0.8,en;q=0.6',
		'Connection'=>'keep-alive',
		'Content-Type'=>'application/x-www-form-urlencoded; charset=UTF-8',
		'Cookie' => cookie,
		#'Referer' => 'http://'+Ip+referer,
		'Host'=>'bms.bgitechsolutions.cn',
		'Origin'=>'http://'+Ip,
		'User-Agent'=>Agent,
		'X-Requested-With'=>'XMLHttpRequest'
		}
	response = Http.post(target,data,headers)
	if(response.code == '200' || response.code == '302')
		return response
	else
		puts "response.code is "+response.code+";body is "+response.body
		exit

	end
end



def bms_close(target,data,referer,cookie)
	headers = {
		'Cookie' => cookie,
		'Referer' => 'http://'+Ip+referer,
		'Content-Type' => ContentType,
		'Connection'=>'keep-alive',
		'User-Agent'=>Agent
	}
	response = Http.post(target,data,headers)
	if(response.code == '302' || response.code == '200')
		return response
	else
		puts "response.code is "+response.code
		exit
	end

end

## step1 fetch cookies
###step1.1 fetch cookie1
puts "start get cookie"
resp, data = Http.get('/newbms/index2.jsp')
if (resp.code == '200')
	Cookie1 = resp.response['set-cookie'].split('; ')[0]
else
	puts "code is " +resp.code
	exit
end
###step1.1 end
###step1.2 fetch cookie2
path = '/newbms/login/chklogin.jsp'
data = 'action=chkuser&username='+user+'&password='+passwd+'&section=深圳&chooseSys=1'
header=
#resp, data = Http.post(path,data,header)
referer='/newbms/index2.jsp'
resp,data = bms_close(path,data,referer,Cookie1)
puts 'log in'
###step1.2 end
## step1 end


## step2.get taskID
time=Time.new
date=time.to_s.split("\s")[0]
target='/newbms/itemTask.htm?cmd=mxListByDay'
data='itemNumber='+bigcode+'&itemMxCode='+subcode+'&startDate='+date
referer='/newbms/ibUI/itemTaskTimeByDay/itemTaskTimeByDay.jsp'
task_id=get_taskid(target,data,referer,Cookie1).body
#puts 'is '+task_id
if task_id=~ /taskId/
	task_id=task_id.gsub(/"taskId":"\w*/).to_a[0].gsub(/"taskId":"/,'')
	puts "taskid is #{task_id}"
	puts 'you already add '+subcode
else
	target='/newbms/itemTask.htm?cmd=addmxListByDay'
	data='data=[{"taskId":null,"itemNumber":"'+bigcode+'","itemMxCode":"'+subcode+'","manName":"'+name+'","manCode":"'+workid+'","taskTime1":null,"taskTime2":null,"taskTime3":null,"taskTime4":null,"taskTime5":null,"taskTime6":null,"taskTime7":null}]'
	referer='/newbms/ibUI/itemTaskTimeByDay/itemTaskTimeByDay.jsp'
	task_id=get_taskid(target,data,referer,Cookie1).body
	puts "taskid 2 is #{task_id}"


	target='/newbms/itemTask.htm?cmd=mxListByDay'
	data='itemNumber='+bigcode+'&itemMxCode='+subcode+'&startDate='+date
	referer='/newbms/ibUI/itemTaskTimeByDay/itemTaskTimeByDay.jsp'
	task_id=get_taskid(target,data,referer,Cookie1).body
	puts 'taskid 3 is '+task_id

end

## step2.end


## step3.fill jobtime
target='/newbms/itemTask.htm?cmd=addmxListByDay'
jobtime='0.1:'+date
data='data=[{"taskId":"'+task_id+'","itemNumber":"'+bigcode+'","itemMxCode":"'+subcode+'","manName":"'+name+'","manCode":"'+workid+'","taskTime1":"'+jobtime+'","taskTime2":null,"taskTime3":null,"taskTime4":null,"taskTime5":null,"taskTime6":null,"taskTime7":null}]'
referer='/newbms/ibUI/itemTaskTimeByDay/itemTaskTimeByDayForWrite.jsp'
fill=bms_close(target,data,referer,Cookie1)
#puts "msg is"+fill.msg
puts "add jobtime ok\n"
## step3.end


## step4. add project path and start time
###step4.1 get itemMxId
target='/newbms/dataProccess.htm?cmd=list'
data='conditions={"itemName":"","itemNumber":"","itemMxName":"","itemMxCode":"'+subcode+'","itemActionInfo":""}&start=0&limit=20'
referer='/newbms/ibUI/dataProccessInput/dataProccessInput.jsp'
itemMxId=bms_close(target,data,referer,Cookie1).body.gsub(/"itemMxId":"\w*/).to_a[0].gsub(/"itemMxId":"/,'')
puts 'itemMxId is'+itemMxId
###step4.1 end
target='/newbms/dataProccess.htm?cmd=update'
data='analysisdataStorageDirectory='+project_path+'&solexaDate='+project_start_date+'&itemMxId='+itemMxId
referer='/newbms/ibUI/dataProccessInput/dataProccessInput.jsp'
#add_project_path=bms_close(target,data,referer,Cookie1)
project_path_date=add_project_path(target,data,referer,Cookie1)
puts 'project path is '+project_path
puts 'project start time is '+project_start_date
if project_path_date.body == '{}'
	puts 'add project path and start time ,ok'
else
	puts 'add project path and start time ,fail'
	exit
end
## step4 end


## step5 request close subcode 
target='/newbms/itemInfoMx.htm?cmd=getItemInfoMxByItemMxId'
data='itemMxId='+itemMxId
referer='/newbms/workflow/bms/request/itemmarket/item_concluded_apply.jsp'
fetch_subcode_info=add_project_path(target,data,referer,Cookie1).body
#puts 'fetch_subcode_info'+fetch_subcode_info
#fetch_subcode_info.gsub!(/质控文件目录：【[^】]*】/,'质控文件目录：【'+zhikong_dir+'】')
#fetch_subcode_info.gsub!(/备份文件目录：【[^】]*】/,'备份文件目录：【'+share_dir+'】')
puts "get fetch_subcode_info"

target='/newbms/itemInfoMx.htm?cmd=applyItemInfoMx'
#itemDelayFlag='否'
itemDelayFlag=fetch_subcode_info.gsub(/"itemDelayFlag":[^,]*/).to_a[1].gsub(/"itemDelayFlag":/,'').force_encoding("UTF-8")
itemLaneNumberg=fetch_subcode_info.gsub(/"itemLaneNumberg":[^,]*/).to_a[0].gsub(/"itemLaneNumberg":/,'')
itemInfoExplain=fetch_subcode_info.gsub(/"itemInfoExplain":"[^"]*/).to_a[0].gsub(/"itemInfoExplain":"/,'')
itemRemarks=fetch_subcode_info.gsub(/"itemRemarks":"[^"]*/).to_a[0].gsub(/"itemRemarks":"/,'')
itemMxName=fetch_subcode_info.gsub(/"itemMxName":"[^"]*/).to_a[0].gsub(/"itemMxName":"/,'')
#itemWorkingDay="15"
itemWorkingDay=fetch_subcode_info.gsub(/"itemWorkingDay":"[^"]*/).to_a[0].gsub(/"itemWorkingDay":"/,'')
contractworkdayC=fetch_subcode_info.gsub(/"contractworkdayC":"[^"]*/).to_a[0].gsub(/"contractworkdayC":"/,'')
#data='object={"itemMxId":"'+itemMxId+'","itemLaneNumberg":'+itemLaneNumberg+',"finishSampleCount":'+sample_num+',"isNormalFinished":"'+close_stat+'","itemInfoExplain":"'+itemInfoExplain.force_encoding("UTF-8")+'","itemEndInfo":"质控记录不完整的原因：【】\n数据备份与BMS信息描述不符的原因：【】\n(注：请在【】中填写)","itemRemarks":"'+itemRemarks.force_encoding("UTF-8")+'","itemResult":"质控文件目录：【'+zhikong_dir+'】\nshare备份文件目录：【'+share_dir+'】\n(注：请在【】中填写)","itemMxName":"'+itemMxName.force_encoding("UTF-8")+'","itemInfoFile":"","itemDelayFlag":"'+itemDelayFlag+'","itemWorkingDay":"'+itemWorkingDay+'","contractworkdayC":"'+contractworkdayC+'"}&flag=0&cexuType=PE'
data='{object={"itemMxId":"'+itemMxId+'","itemLaneNumberg":'+itemLaneNumberg+',"finishSampleCount":'+sample_num+',"isNormalFinished":"'+close_stat+'","itemInfoExplain":"'+itemInfoExplain.force_encoding("UTF-8")+'","itemEndInfo":"质控记录不完整的原因：【】\n数据备份与BMS信息描述不符的原因：【】\n(注：请在【】中填写)","itemRemarks":"'+itemRemarks.force_encoding("UTF-8")+'","itemResult":"质控文件目录：【'+zhikong_dir+'】\nshare备份文件目录：【'+share_dir+'】\n(注：请在【】中填写)","itemMxName":"'+itemMxName.force_encoding("UTF-8")+'","itemInfoFile":"","itemDelayFlag":"'+itemDelayFlag+'","itemWorkingDay":"'+itemWorkingDay+'","contractworkdayC":"'+contractworkdayC+'"}&flag=0&cexuType=PE}'
puts "data is "+data
data.gsub!(/质控记录不完整的原因：【[^】]*】/,'质控记录不完整的原因：【'+zhikong_uncomplete_reason+'】')
data.gsub!(/数据备份与BMS信息描述不符的原因：【[^】]*】/,'数据备份与BMS信息描述不符的原因：【'+share_uncomplete_reason+'】')
request=add_project_path(target,data,'',Cookie1).body
puts 'requset is '+request
if request == '{}'
	puts 'upload close repquest  ,ok'
else
	puts 'upload close repquest ,fail'
	exit
end
## step5 end


## step6 shenhe request
## get request info
target='/newbms/itemInfoMx.htm?cmd=getItemInfoMxByItemMxId'
data='itemMxId='+itemMxId
request=add_project_path(target,data,'',Cookie1).body
#puts 'request info is '+request
itemInfoExplain=itemInfoExplain.force_encoding("UTF-8")
data='object={"itemMxId":"'+itemMxId+'","itemAddPearnid":"'+itemMxId+'","itemInfoExplain":"'+itemInfoExplain+'","itemEndInfo":"质控记录不完整的原因：【】\n数据备份与BMS信息描述不符的原因：【】\n(注：请在【】中填写)","itemRemarks":"","itemIntro":""}'
data.gsub!(/质控记录不完整的原因：【[^】]*】/,'质控记录不完整的原因：【'+zhikong_uncomplete_reason+'】')
data.gsub!(/数据备份与BMS信息描述不符的原因：【[^】]*】/,'数据备份与BMS信息描述不符的原因：【'+share_uncomplete_reason+'】')
#puts 'step6 '+data
target='/newbms/itemInfoMx.htm?cmd=passAuditItemInfoMx'
check=add_project_path(target,data,'',Cookie1).body
puts 'check is '+check
if check == '{"flag":true}'
	puts bigcode+'_'+subcode+' 审核通过!'
else
	puts bigcode+'_'+subcode+' 审核不通过!'
	exit
end

## step6 end

