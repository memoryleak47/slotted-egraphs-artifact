(lambda R (lambda S
	(sum k1 v1 (var R) (sum k2 v2 (var S) (ifthen (== (var v1) (var v2)) (* (var k1) (var v1)))))
))