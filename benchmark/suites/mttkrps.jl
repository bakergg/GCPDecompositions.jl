module BenchmarkMTTKRPS

using BenchmarkTools, GCPDecompositions
using Random

const SUITE = BenchmarkGroup()

# Collect setups
const SETUPS = []

# 3 modes, balanced
append!(
    SETUPS,
    [
        (; modes=3, size = sz, rank = r) for
        sz in [ntuple(n -> In, 3) for In in 50:50:200], r in 50:50:300
    ],
)

# 4 modes, balanced
append!(
    SETUPS,
    [
        (; modes=4, size = sz, rank = r) for
        sz in [ntuple(n -> In, 4) for In in 50:50:100], r in 50:50:300
    ],
)

# 5 modes, balanced
append!(
    SETUPS,
    [
        (; modes=5, size = sz, rank = r) for
        sz in [ntuple(n -> In, 5) for In in 20:20:40], r in 50:50:300
    ],
)

# Function to set up and run 1 MTTKRPS
function mttkrps_testing(X, r)
    # Setup GCP for 1 iteration
    M0 = GCPDecompositions.CPD(ones(T, r), rand.(T, size(X), r))
    M0norm = sqrt(sum(abs2, M0[I] for I in CartesianIndices(size(M0))))
    Xnorm = sqrt(sum(abs2, skipmissing(X)))
    for k in Base.OneTo(N)
        M0.U[k] .*= (Xnorm / M0norm)^(1 / N)
    end
    λ, U = M0.λ, collect(M0.U)
    # Compute MTTKRP for all modes
    for n in 1:ndims(X)
        V = reduce(.*, U[i]'U[i] for i in setdiff(1:N, n))
        U[n] = mttkrp(X, U, n) / V
        λ = norm.(eachcol(U[n]))
        U[n] = U[n] ./ permutedims(λ)
    end
    return
end


# Generate random benchmarks
for SETUP in SETUPS
    Random.seed!(0)
    X = randn(SETUP.size)
    SUITE["modes=$(SETUP.modes), size=$(SETUP.size), rank=$(SETUP.rank)"] = @benchmarkable(
        mttkrps_testing(X, SETUP.rank),
        seconds = 5,
        samples = 5,
    )
end





end
