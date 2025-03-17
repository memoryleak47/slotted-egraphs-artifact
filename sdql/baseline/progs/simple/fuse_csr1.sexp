(lambda Row (lambda N 
	(let R (sum i j (range 1 (var N)) (sing (unique (var j)) (get (var Row) (var j))))
		(sum i2 j2 (var R) (var j2))
	)
))