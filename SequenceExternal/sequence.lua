local sequence = pd.Class:new():register("sequence")

function sequence:initialize(sel, atoms)
    -- validate atoms
    if type(atoms[1]) ~= "number" or type(atoms[2]) ~= "number" or type(atoms[3]) ~= "number" or type(atoms[4]) ~= "number" then 
        pd.post("sequence requires 4 arguments")
        -- object fails to create
        return false 
    end
    self.inlets = 1
    self.outlets = 2
    self.index = 1
    self.atoms = atoms
    self.minValue = math.floor(atoms[1])
    self.maxValue = math.floor(atoms[2])
    self.minLength = math.floor(atoms[3])
    self.maxLength = math.floor(atoms[4])
    self.length = math.random(self.minLength, self.maxLength)
    self.sequence = {}
    for i = 1, self.length do
        self.sequence[i] = math.random(self.minValue, self.maxValue)
    end
    self:print()
    return true
end

function sequence:choose()
    -- either add or remove, depending on length and a random factor
    if self.length < self.maxLength and self.length > self.minLength then
        if math.random() < 0.5 then
            self:add()
        else
            self:remove()
        end
    else
        if self.length >= self.maxLength then 
            self:remove()
        else
            self:add()
        end
    end
    self:print()
end

function sequence:next()
    self:outlet(1, "float", { self.sequence[self.index] })
    self.index = self.index + 1
    if self.index > self.length then
        self.index = 1
    end
end

function sequence:print()
    self:outlet(2, "list", self.sequence)
    pd.post("sequence:")
    for i = 1, self.length do
        pd.post(self.sequence[i])
    end
end

function sequence:add()
    -- add an integer in a range somewhere in the sequence
    if self.length < self.maxLength then
        index = math.random(self.length)
        value = math.random(self.minValue, self.maxValue)
        newSequence = {}
        for i = 1, self.length + 1 do 
            if i < index then
                newSequence[i] = self.sequence[i]
            end
            if i == index then
                newSequence[i] = value
            end
            if i > index then
                newSequence[i] = self.sequence[i - 1]
            end
        end
        self.sequence = newSequence
        self.length = self.length + 1
        if self.index > index then
            self.index = self.index + 1
        end
    end
end

function sequence:remove()
    -- remove one of the integers
    if self.length > self.minLength then
        index = math.random(self.length)
        newSequence = {}
        for i = 1, self.length - 1 do
            if i < index then
                newSequence[i] = self.sequence[i]
            end
            if i > index then
                newSequence[i - 1] = self.sequence[i]
            end
        end
    end
    self.length = self.length - 1
end

function sequence:in_1_bang()
    self:next()
end

function sequence:in_1_choose()
    self:choose()
end

function sequence:in_1_add()
    self:add()
end

function sequence:in_1_remove()
    self:remove()
end

function sequence:in_1_print()
    self:print()
end
