local markovChain = new pd.Class:new():register('markovChain')

function markovChain:initialize(sel, atoms)
    -- 'next' or 'bang' sets and outputs the next value
    -- 'this' or 'current' reoutputs the current value
    -- 'reset' sets a new random matrix with the instantiated args
    -- 'print' prints the matrix
    self.inlets = 1
    self.outlets = 1
end

function markovChain:in_1_bang()
    pd.post("got a bang!")
end