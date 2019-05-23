#!/bin/bash
#---------------------------------------------------
#在给定的路径下，遍历其目录下所有的压缩包
#解压后，进入其对应的目录，拷贝四个文件到工程文件下
#执行后，将结果记录到result.txt文档
#格式形如下
#AirplaneLD-PT-0010
#TTFFFF...
#FTTFTF...
#
#Angiogenesis-PT-01
#FFFFFF...
#FFTFTF...
#---------------------------------------------------

project_dir="/home/tvtaqa/Documents/enPAC-2020-2.0/cmake-build-debug"  #enPAC工程路径
result="/home/tvtaqa/Documents/code/result.txt"   #result.txt的绝对路径
csv="/home/tvtaqa/Documents/code/mc_data.csv"    #.csv的绝对路径
input_dir="/home/tvtaqa/Documents/input"   #测试集的路径

    for element in `ls $input_dir` #遍历整个测试集
    do  
	#判断是否是file
	dir_or_file=$input_dir"/"$element
 
	#解压到当前目录
        tar zxvf $dir_or_file -C $input_dir 

        #echo ${element%.*} #去掉.后缀
	temp=$input_dir"/"${element%.*}"/"
	
	#进入解压得到的文件夹
	cd $temp 

	#拷贝四个文件到工程目录
	cp LTLCardinality.xml $project_dir
	cp LTLFireability.xml $project_dir
	cp model.pnml $project_dir
	cp iscolored $project_dir

	#运行
	enPAC_exe=$project_dir"/enPAC_2020_2_0"
 	arg1=$(echo `$enPAC_exe` ) 
	
	#将该例子的名字先写到result.txt中
	echo "${element%.*}" >> $result 
	
	#get the lines of the boolresult.txt
	linenum=0
	for line in `cat boolresult.txt`
	do
		linenum=$(($linenum+1)) 
	done 

	# boolresult.txt 非空
	if [ $linenum -eq 2 ];then  
        	cat boolresult.txt >> $result
        	echo "" >> $result
        	echo "" >> $result
	elif [ $linenum -eq 1 ];then
		cat boolresult.txt >> $result
		echo "" >> $result
		echo "NULL" >> $result
        	echo "" >> $result
	else  # boolresult.txt 空
		echo "NULL" >> $result
		echo "NULL" >> $result
		echo "" >> $result
	fi
    done
#----------------------------------------------------
#array[0]保存例子的名称
#array[1]保存LTLC的结果
#array[1]保存LTLF的结果
# result文件每三行是一个例子（忽略空行）
#根据array[0]找到csv文件相应的位置，在其下方插入即可
#----------------------------------------------------
i=0
my_array=(A B C)
for line in `cat $result`
do
	#echo $line
	
	array[${i}%3]=$line
	#echo ${array[${i}%3]}

	#数组存满->将数据写入csv文件
	let t=(${i}+1)%3
	if [ $t -eq 0 ]
	then 
		#得到在csv文件的行号
		num=`grep -n "^${array[0]}" $csv` 

		# ${num%:*} 取冒号前面的行号
		#echo ${num%:*} 
		
		#在csv文件中找到该例子
		if [[ ${num%:*} -gt 0 ]];then

		#需要插入的信息（TTTFF...）
		adinfo=",,"${array[1]}","${array[2]}   
   
		#找到相应的行 在下面一行插入结果
		sed -i ${num%:*}a\ $adinfo $csv
   
		#该例子不在csv文件中
		else
			echo "${array[0]} does not exist in .csv" 
		fi
	fi

	#i++
	i=$(($i+1))      				
done



