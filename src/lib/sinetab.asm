#importonce
.filenamespace SinusTableGenerator

.function @SineTab(length, min, max){
	.print "[INF] Generating sine curve with " + length +  " elements between " + min + " and " + max + " (Amplitude: " + [max - min] + ")"

	.var list = List(length)
	.for(var i = 0; i < length; i++) {
		.var value = min+[[1 + [sin(toRadians(i*360/length))]]/2.0] * [max-min]
		//.print round(value)
		.eval list.set(i, round(value))
	}
	.return list
}
.function @SineTab(length, min, max, offset){
	.print "[INF] Generating sine curve with " + length +  " elements between " + min + " and " + max + " (Amplitude: " + [max - min] + ", offset: " + offset +")"

	.var list = List(length)

	.for(var i = 0; i < length; i++) {
		.var value = min+[[1 + [sin(toRadians(i*360/length))]]/2.0] * [max-min]
		.eval list.set(mod(i + offset, length), round(value))
	}
	.return list
}
