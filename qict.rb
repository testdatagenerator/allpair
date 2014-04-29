def NumberPairsCaptured(ts, unusedPairsSearch)
	ans = 0
	for i in 0..ts.length-2 do
		for j in i+1..ts.length-1 do
			if unusedPairsSearch[ts[i]][ts[j]] == 1
				ans+=1
			end
		end
	end
	ans.to_s
end


r = Random.new

poolSize = 20

Param = []
Param0 = ['a', 'b']
Param1 = ['c', 'd', 'e', 'f']
Param2 = ['g', 'h', 'i']
Param3 = ['j', 'k']

Param << Param0
Param << Param1
Param << Param2
Param << Param3

#配列を読み込み、因子と水準を設定
numberParameters = Param.length
numberParameterValues = 0
Param.each do |p|
	numberParameterValues += p.length
end
puts "There are " + numberParameters.to_s + " parameters"
puts "There are " + numberParameterValues.to_s + " parameter values"


#因子毎に定義している水準をlegalValuesの2次元配列に設定
legalValues = Array.new(numberParameters)
parameterValues = []
currRow = 0
kk = 0
Param.each do |p|
	strValues = p
	values = Array.new(p.length)

	for i in 0..strValues.length-1 do
		values[i] = kk
		parameterValues[kk] = strValues[i]
		kk+=1
	end

	legalValues[currRow] = values
	currRow+=1
end

puts "Parameter values: "
for i in 0..parameterValues.length-1 do
	print parameterValues[i].to_s + " "
end
puts ""

puts "Legal values internal representation: "
for i in 0..legalValues.length-1 do
	print "Parameter" + i.to_s + ": "
	for j in 0..legalValues[i].length-1 do
		print legalValues[i][j].to_s + " "
	end
	puts ""
end


#各因子が持つ水準の全ての組み合わせ数を求める
numberPairs = 0
for i in 0..legalValues.length-2 do
	for j in i+1..legalValues.length-1 do
		numberPairs += legalValues[i].length * legalValues[j].length
	end
end
puts "There are " + numberPairs.to_s + " pairs "

#前処理で求めた組み合わせ数のペアを取得し、それをunusedPairsのリストの要素として追加する
#allPairsDisplay = Array.new(numberPairs, 2)
allPairsDisplay = Array.new(numberPairs).map!{ Array.new(2, 0) }

unusedPairs = Array.new
unusedPairsSearch = Array.new(numberParameterValues).map!{ Array.new(numberParameterValues, 0) }
currPair = 0

for i in 0..legalValues.length-2 do
	for j in i+1..legalValues.length-1 do
		firstRow = legalValues[i]
		secondRow = legalValues[j]
		for x in 0..firstRow.length-1 do
			for y in 0..secondRow.length-1 do
				allPairsDisplay[currPair][0] = firstRow[x]
				allPairsDisplay[currPair][1] = secondRow[y]

				aPair = Array.new(2)
				aPair[0] = firstRow[x]
				aPair[1] = secondRow[y]
				unusedPairs << aPair
				unusedPairsSearch[firstRow[x]][secondRow[y]] = 1

				currPair+=1
			end
		end
	end
end
=begin
puts "allPairsDisplay array:"
for i in 0..numberPairs-1 do
	puts i.to_s + " " + allPairsDisplay[i][0].to_s + " " + allPairsDisplay[i][1].to_s
end
=end

puts "unusedPairsSearch:"
for i in 0..unusedPairsSearch.length-1 do
	for j in 0..unusedPairsSearch[i].length-1 do
		print unusedPairsSearch[i][j].to_s
		if j < unusedPairsSearch[i].length-1
			print ","
		end
	end
	puts ""
end


puts "unusedPairs array:"
for i in 0..numberPairs-1 do
	if unusedPairs[i] != nil
		puts i.to_s + " " + unusedPairs[i][0].to_s + " " + unusedPairs[i][1].to_s
	end
end

#パラメータ位置のポジションを設定
parameterPositions = Array.new(numberParameterValues, 0)
k = 0
for i in 0..legalValues.length-1 do
	curr = legalValues[i]
	for j in 0..curr.length-1 do
		parameterPositions[k] = i
		k+=1
	end
end
puts "parameterPositions:"
for i in 0..parameterPositions.length-1 do
	print parameterPositions[i].to_s + " "
end
puts ""

#全ての組み合わせを表現したallPairsDisplayから、各因子がいくつ使用しているかを
#unusedCountsに設定
unusedCounts = Array.new(numberParameterValues, 0)
for i in 0..allPairsDisplay.length-1 do
	unusedCounts[allPairsDisplay[i][0]] += 1
	unusedCounts[allPairsDisplay[i][1]] += 1
end
puts "unusedCounts: "
for i in 0..unusedCounts.length-1 do
	print unusedCounts[i].to_s + " "
end
puts ""

#メイン処理
testSets = []
puts "Computing testsets which capture all possible pairs . . ."
while unusedPairs.length > 0 do

	candidateSets = []

	for candidate in 0..poolSize-1 do
		testSet = Array.new(numberParameters, 0)

		bestWeight = 0
		indexOfBestPair = 0
		for i in 0..unusedPairs.length-1 do
			curr = unusedPairs[i]
			weight = unusedCounts[curr[0]] + unusedCounts[curr[1]]
#			puts "bestWeight = " + bestWeight.to_s + ", weight = " + weight.to_s
			if weight > bestWeight
				bestWeight = weight
				indexOfBestPair = i
			end

#			puts "i=" + i.to_s + ", curr[0] = " + curr[0].to_s + ", curr[1] = " + curr[1].to_s + ", unusedCounts[" + curr[0].to_s + "] = " + unusedCounts[curr[0]].to_s + ", unusedCounts[" + curr[1].to_s + "] = " + unusedCounts[curr[1]].to_s
		end

		best = unusedPairs[indexOfBestPair].dup
		firstPos = parameterPositions[best[0]]
		secondPos = parameterPositions[best[1]]
		puts "best = " + best.to_s + ", firstPos = " + firstPos.to_s + ", secondPos = " + secondPos.to_s

		ordering = Array.new(numberParameters, 0)
		for i in 0..numberParameters-1 do
			ordering[i] = i
		end
		ordering[0] = firstPos
		ordering[firstPos] = 0

		t = ordering[1]
		ordering[1] = secondPos
		ordering[secondPos] = t

		for i in 2..ordering.length-1 do
			j = r.rand(i..ordering.length-1)
			temp = ordering[j]
			ordering[j] = ordering[i]
			ordering[i] = temp
		end

=begin		
		puts "Order: "
		for i in 0..ordering.length-1 do
			print ordering[i].to_s + " "
		end
		puts ""
=end

		testSet[firstPos] = best[0]
		testSet[secondPos] = best[1]

		for i in 2..numberParameters-1 do
			currPos = ordering[i]
			possibleValues = legalValues[currPos].dup

			currentCount = 0
			highestCount = 0
			bestJ = 0
			for j in 0..possibleValues.length-1 do
				currentCount = 0
				for p in 0..i-1 do
					candidatePair = [possibleValues[j], testSet[ordering[p]]]
					if unusedPairsSearch[candidatePair[0]][candidatePair[1]] == 1 ||
						unusedPairsSearch[candidatePair[1]][candidatePair[0]] == 1
						currentCount += 1
					else
					end
				end
				if currentCount > highestCount
					highestCount = currentCount
					bestJ = j
				end
			end
			testSet[currPos] = possibleValues[bestJ]
		end
		candidateSets[candidate] = testSet
#		break
	end

	puts "Candidates testSets are: "
	for i in 0..candidateSets.length-1 do
		curr = candidateSets[i].dup
		print i.to_s + ": "
		for j in 0..curr.length-1 do
			print curr[j].to_s + " "
		end
		puts " -- captures " + NumberPairsCaptured(curr, unusedPairsSearch)
	end

	indexOfBestCandidate = r.rand(candidateSets.length)
	mostPairsCaptured = NumberPairsCaptured(candidateSets[indexOfBestCandidate], unusedPairsSearch)

	for i in 0..candidateSets.length-1 do
		pairsCaptured = NumberPairsCaptured(candidateSets[i], unusedPairsSearch)
		indexOfBestCandidate = i
	end
	bestTestSet = candidateSets[indexOfBestCandidate].dup
	testSets << bestTestSet

	for i in 0..numberParameters-2 do
		for j in i+1..numberParameters-1 do
			v1 = bestTestSet[i]
			v2 = bestTestSet[j]

			unusedCounts[v1] -= 1
			unusedCounts[v2] -= 1
	
			unusedPairsSearch[v1][v2] = 0

			removePairs = [] #独自追加(forの中で要素を削除すると順番が狂うので配列に一度格納したあとに削除)
			for p in 0..unusedPairs.length-1 do
				curr = unusedPairs[p]
				if curr[0] == v1 && curr[1] == v2
						removePairs << p
				end
			end
			removePairs.reverse_each do |r|
				unusedPairs.delete_at(r)
			end
		end
	end

#	break
end

puts "Result testsets: "
for i in 0..testSets.length-1 do
	print i.to_s + ": "
	curr = testSets[i]
	for j in 0..numberParameters-1 do
		print parameterValues[curr[j]].to_s + " "
	end
	puts ""
end



