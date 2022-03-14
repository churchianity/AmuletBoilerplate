
math.randomseed(os.time())

local R = math.random
RANDOM_CALLS_COUNT = 0
function random(n, m)
    RANDOM_CALLS_COUNT = RANDOM_CALLS_COUNT + 1

    -- we can't seem to just call R(n, m) all the time...
    if n then
        if m then
            return R(n, m)
        else
            return R(n)
        end
    else
        return R()
    end
end

-- whenever we refer to math.random, actually use the function 'random' above
math.random = random

-- the random number generator by default kinda sucks if you don't seed it and discard a few values before using it.
math.random()
math.random()
math.random()
math.random()

-- @TODO test
function gnoise(x, y, num_octaves, seed)
    local seed = seed or os.time()
    local noise = 0

    for oct = 1, num_octaves do
        local f = 1/4^oct
        local l = 2^oct
        local pos = vec2(x + seed, y + seed)
        noise = noise + f * math.simplex(pos * l)
    end

    return noise
end

-- @TODO test, fix
function poisson_knuth(lambda)
    local e = 2.71828

    local L = e^-lambda
    local k = 0
    local p = 1

    while p > L do
        k = k + 1
        p = p * math.random()
    end

    return k - 1
end

