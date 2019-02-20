local tuningSystem = pd.Class:new():register("tuningSystem")
local primes = {2, 3, 5, 7, 13, 17, 19, 23, 29, 31}

function tuningSystem:initialize(sel, atoms)
    -- settable
    -- the tone in hz from which to tune the other tones
    self.baseTone = 440
    -- the interval over which the tuning system repeats
    self.outerInterval = 2.0
    -- the number of intervals between outer intervals, exclusive
    self.divisions = 11
    -- the number of primes allowable as interval divisors
    self.primeIntervalDivisors = 3
    -- the highest allowable power of any divisor
    self.highestPower = 2

    -- not settable
    -- an integer for the index of the tone
    self.inlets = 1
    -- outputs the tone in hz
    self.outlets = 1
    -- the lowest needed tone
    self.lowestTone = 10
    -- the highest needed tone
    self.highestTone = 48000
    -- available primes
    self.primes = {}
    for i = 0, self.primeIntervalDivisors, 1 do
        self.primes[i] = primes[i]
    end
    -- available factors
    self.factors = {}
    -- available intervals
    self.intervals = {}
    -- tones, to be indexed by an octave-like outer interval
    self.tones = {}
    -- lowest outer interval - the lowest index to begin cycling the tuning system upward
    index = 1
    local dividedBaseTone = self.baseTone
    while dividedBaseTone > self.lowestTone do
        index = index - 1
        dividedBaseTone = dividedBaseTone / self.outerInterval
    end
    self.lowestOuterInterval = index
    self.lowestAvailableTone = dividedBaseTone
    self.baseToneInterval = -self.lowestOuterInterval + 2
    -- current outer interval
    self.currentOuterInterval = self.baseToneInterval

    self:generateFactors()
    self:generateIntervals()
    self:chooseIntervals()
    self:generateTones()
    return true
end

function tuningSystem:generateFactors()
    -- generate all possible factors
    permutations = self.primes
    for j = 1, self.highestPower do
        for _, prime in ipairs(self.primes) do
            newPermutations = {}
            for __, permutation in ipairs(permutations) do
                permutation = permutation * prime
                table.insert(newPermutations, permutation)
            end
        end
        for __, p in ipairs(newPermutations) do
            table.insert(permutations, p)
        end
    end
    self.factors = permutations
end

function tuningSystem:generateIntervals()
    -- generate all possible intervals
    for _, divisor in ipairs(self.factors) do
        for n = 1, divisor, 1 do
            interval = n / divisor
            found = false
            for __, value in ipairs(self.intervals) do
                if found == false and value == interval then
                    found = true
                end
            end
            if found == false then
                table.insert(self.intervals, interval)
            end
        end
    end
end

function tuningSystem:chooseIntervals()
    -- choose the intervals
    if self.divisions - 2 > #self.intervals then
        pd.post("not enough divisions")
    end
    self.chosenIntervals = {0}
    local remainingIntervals = self.intervals
    for i = 1, self.divisions, 1 do 
        intervalIndex = math.random(#remainingIntervals)
        local interval = remainingIntervals[intervalIndex]
        table.insert(self.chosenIntervals, interval)
        table.remove(remainingIntervals, intervalIndex)
    end
    table.sort(self.chosenIntervals)
end

function tuningSystem:generateTones()
    -- index tones upward by outer interval
    baseTone = self.lowestAvailableTone
    intervalIndex = 1
    while baseTone < self.highestTone do
        local outerIntervalArray = {}
        for _, value in ipairs(self.chosenIntervals) do
            table.insert(outerIntervalArray, (1 + value) * baseTone)
        end
        baseTone = baseTone * self.outerInterval
        self.tones[intervalIndex] = outerIntervalArray
        intervalIndex = intervalIndex + 1
    end
    self:print()
end

function tuningSystem:print() 
    pd.post("base tone interval: " .. self.baseToneInterval)
    pd.post("lowest outer interval: " .. self.lowestOuterInterval)
    pd.post("tones:")
    for index, interval in ipairs(self.tones) do
        pd.post("outerIntervalIndex: " .. index)
        for __, tone in ipairs(interval) do
            pd.post("tone: " .. tone)
        end
    end
end

function tuningSystem:in_1(sel, atoms)
    pd.post("sel: " .. sel)
    for index, atom in ipairs(atoms) do 
        pd.post(index)
        pd.post(atom)
    end
    if (sel == "oi" or sel == "octave") and atoms[1] and type(atoms[i]) == "number" then
        self.currentOuterInterval = atoms[1]
    end
    if sel == "tone" and atoms[1] and type(atoms[i]) == "number" then
        local n = atoms[i]
        self:get(n)
    end
end

function tuningSystem:in_1_float(f)
    self:get(f)
end

function tuningSystem:get(f)
    f = math.floor(f)
    pd.post(f)
    local tone = self.tones[self.currentOuterInterval][f]
    if f >= 0 and f < self.divisions then
        self:outlet(1, "float", {tone})
    end
end

-- function tuningSystem:get(f)
--     self:outlet(1, "float", { self.tones[math.floor(f)]} )
-- end

-- function tuningSystem:in_1_float(f)
--     self:get(f)
-- end

-- function tuningSystem:in_1_print()
--     self.print()
-- end