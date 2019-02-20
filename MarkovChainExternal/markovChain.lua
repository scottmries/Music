local markovChain = pd.Class:new():register('markovChain')

function markovChain:initialize(sel, atoms)
    -- 'next' or 'bang' sets and outputs the next value
    -- 'this' or 'current' reoutputs the current value
    -- 'reset' sets a new random matrix with the instantiated args
    -- 'print' prints the matrix
    self.inlets = 1
    self.outlets = 1
    self.atoms = atoms
    self.minValue = atoms[0]
    return true
end

function markovChain:in_1_bang()
    for i=1,table.getn(self.atoms)
        do pd.post(i)
    end
    return true
end