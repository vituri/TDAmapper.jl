# Ball Mapper
include("Mapper.jl");
include("neighborhoods.jl");
include("sampling.jl");

X = rand(Float32, 2, 1000)
ϵ = 0.1
landmarks = epsilon_net(X, ϵ)
L = X[landmarks, :]

function neighborhood_vertex(X::PointCloud, L::PointCloud; radius = 0.1, distance = Euclidean())
    n = size(L)[1]
    covering = empty_covering(n)
    
    p = Progress(n)    
    Base.Threads.@threads for i = 1:n
        distances = colwise(distance, L[i, :], X)
        covering[i] = epsilon_neighbors(distances, radius)    
        next!(p)
    end
    
    return covering   
end

covering = neighborhood_vertex(X, L)

X_covered = CoveredSpace(X, covering)

function ball_mapper(X::PointCloud, L::PointCloud, vertex_function = neighborhood_vertex)
    covering = vertex_function(X, L)    
    adj_matrix = adj_matrix_from_covering(covering)
    G = Graph(adj_matrix)

    return G
end

G = ball_mapper(X, L)