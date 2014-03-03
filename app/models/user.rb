class User < ParseUser
	alias :email :username

	EMAILNOTIFYTEST = ["nitish.verma@trantorinc.com","mahinder.kumar@trantorinc.com","kirandeep.kaur@trantorinc.com","rajat.julka@trantorinc.com"]
	EMAILNOTIFYMAIN = ["rajat.julka@trantorinc.com","raj.kondal@trantorinc.com","pradeep@trantorinc.com","sriram@trantorinc.com"]

end