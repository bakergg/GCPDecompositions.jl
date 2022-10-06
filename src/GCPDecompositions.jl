"Generalized CP Decomposition module. Provides approximate CP tensor decomposition with respect to general losses."
module GCPDecompositions

# Imports
import Base: require_one_based_indexing
import Base: ndims, size, show, summary

# Exports
export CPD
export ncomponents

include("type-cpd.jl")

end
