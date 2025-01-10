#!/bin/bash
echo "Enter the show conn file name in current directory or full path name"
read filename
echo "Enter the number of top hosts, ports, sockets, IP pair required"
read nums

echo "Top IP ADDRESS" > ip.temp
echo "Top PORTS" > port.temp
echo "Top SOCKETS" > socket.temp
echo "Top PAIR of ADDRESS" > pair.temp

cat $filename | awk 'BEGIN{OFS = "\n"}
{
	#Next line is removing the commas from each line
	gsub(",", "", $0)
	#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different. 
	if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")
	{
		#Next two line removes the ":" between the IP address and ports.
		 sub(":", " ", $0)
		 sub(":", " ", $0)
		print $3,$6
	}
	else
	{	#Next line is printing the IP address in connections without ports such as EIGRP
		print $3,$5
	}
}
END{}' | awk 'BEGIN{}
{a[$1]++}
END{for(x in a)print a[x]" "x}
' | sort -rnk1 | head -$nums >> ip.temp &
cat $filename | awk 'BEGIN{OFS = "\n"}
{
	#Next line is removing the commas from each line
	gsub(",", "", $0)
	#Next line is checking if the first column value is TCP,UDP as this would be most common use case
	if($1 == "TCP" || $1 == "UDP")
	{
		#Next two line removes the ":" between the IP address and ports.
		 sub(":", " ", $0)
		 sub(":", " ", $0)
		print $4,$7
	}
}
END{} '  | awk 'BEGIN{}
{a[$1]++}
END{for(x in a)print a[x]" "x}
' | sort -rnk1 | head -$nums >> port.temp &
 cat $filename | awk 'BEGIN{OFS = "\n"}
{
	#Next line is removing the commas from each line
	gsub(",", "", $0)
	#Next line is checking if the first column value is TCP,UDP most common case
	if($1 == "TCP" || $1 == "UDP")
	{
		#Next two line removes the ":" between the IP address and ports.
		 sub(":", " ", $0)
		 sub(":", " ", $0)
		print $3":"$4
	}
}
END{}
' | awk 'BEGIN{}
{a[$1]++}
END{for(x in a)print a[x]" "x}
' | sort -nrk1 | head -$nums >> socket.temp &
cat $filename | awk 'BEGIN{OFS = "\n"}
{
	#Next line is removing the commas from each line
	gsub(",", "", $0)
	#Next line is checking if the first column value is TCP,UDP,ICMP,GRE as for portless connections such as EIGRP etc column will be different. 
	if($1 == "TCP" || $1 == "UDP" || $1 == "ICMP" || $1 == "GRE")
	{
		#Next two line removes the ":" between the IP address and ports.
		 sub(":", " ", $0)
		 sub(":", " ", $0)
		print $3"<->"$6
	}
	else
	{	#Next line is printing the IP address pair in connections without ports such as EIGRP
		print $3"<->"$5
	}
}
END{}' | awk 'BEGIN{}
{a[$1]++}
END{for(x in a)print a[x]" "x}
' | sort -nrk1 | head -$nums >> pair.temp &

wait
cat ip.temp port.temp socket.temp pair.temp
rm ip.temp port.temp socket.temp pair.temp


