###Result
1. x小时x分钟
		
		[(（](\d+小时)?(\d+分钟)?[)）]
		[(（](\d+(h|hour|hours|时|小时))?(\d+(m|minute|minutes|分|分钟))?[)）]    #also match '()'
		
2. 时间，如：11：12 am/pm/a.m.

		\b[0-2]?\d[:：][0-5]\d(( )?(am|pm|a\.m\.|p\.m\.))?


###Case

		1. 完成头条剩余工作 （1小时）到11：22 
		2. DFA NFA学习 （3小时15分钟）到学透彻 start:2:37
		3. 完成Oneday SMDetector，修复bug （剩余时间） 
		4. 头条bug修复（depend）
		
		1. 完成头条剩余工作 1小时 到11：22 
		2. DFA NFA学习 (3小时15分钟) 到学透彻 start:2:37
		3. 完成Oneday SMDetector，修复bug （剩余时间）(15分钟) 
		4. 头条bug修复（depend）
		
		1. 完成头条剩余工作 （1小时）到11：22 
		2. DFA NFA学习 （3小时15分钟）到学透彻 start:2:37
		3. 完成Oneday SMDetector，修复bug （剩余时间） 
		4. 头条bug修复（depend）()

###Query
1.

		(h|hour|hours|时|小时) (m|minute|minutes|分|分钟)
		
2.
		
		(am|pm|a.m.|p.m.)
		
###Q&A
1. 下面的表达式可以匹配“x小时x分钟”，但是也会把单纯的“()”匹配出来

		[(（](\d+小时)?(\d+分钟)?[)）]
		
2.
	* Q: 如何匹配这样一组字符串:["h", "hour", "hours", "时", "小时"]？就像[aeiou]一样。
	* A:	
	
			\d(hours|小时)

		