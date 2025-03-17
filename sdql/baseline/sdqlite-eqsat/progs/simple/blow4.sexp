(lambda a
	(lambda b
		(let x (let y (* (var a) (var b)) (+ (var y) (* (var y) (var b)))) (+ (var x) (* (var x) (var b))))
	)
)