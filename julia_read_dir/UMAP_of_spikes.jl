
using UMAP
using Conda
using PyCall

py"""
def send_to_Julia_namespace():
  import pickle
  try:
    input_raster = np.load(data_folder+'input_raster.npz')
    spikes_list = pickle.load(open("../plots/spikes_for_julia_read.p","rb"))
    return (spikes_list[0],spikes_list[1])
  except:
    return (None,None)
"""

(spikes_list0,spikes_list1) = py"send_to_Julia_namespace"()
@show(spikes_list0)
@show(spikes_list1)

using HDF5
using Plots
using StatsBase
using Random
hf5 = h5open("output/spikes.h5","r")
nodes = Vector{Int64}(read(hf5["spikes"]["v1"]["node_ids"]))
times = Vector{Float64}(read(hf5["spikes"]["v1"]["timestamps"]))

close(hf5)
function raster(nodes,times)
    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end
    size = (800,600)

    p0 = Plots.plot(;size,leg=false,title="spike train",grid=false)

    scatter(p0,xs,ys;label="SpikeTrain",markershape=:vline,markersize=ms,markerstrokewidth = 0.5)

    savefig("Better_Spike_Rastery.png")
end

#raster(p,times)

#times = Vector{Float64}(read(h5open("spikes.h5","r")["spikes"]["v1"]["timestamps"]))

function raster(nodes,times)

    #=
    Don't forget to make a normalized raster plot
    =#
    size = (800,600)
    p0 = Plots.plot(;size,leg=false,title="spike train",grid=false)
    markersize=0.0001#ms
    scatter(p0,times,nodes;label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.00015)

    savefig("Better_Spike_Rastery.png")
end

#@time raster(nodes,times)

function PSTH0(nodes,times)
    temp = size(nodes)[1]
    bin_size = 5 # ms
    bins = collect(1:bin_size:temp)
    markersize=0.001#ms
    l = @layout [a ; b]
    p1 = scatter(times,nodes;bin=bins,label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.015, legend = false)
    p2 = plot(stephist(times, title="PSTH", legend = false))
    size_ = (800,600)

    Plots.plot(p1, p2, layout = l,size=size_) 
    #savefig("PSTH.png")

end
function PSTH(nodes,times)
    #temp = size(nodes)[1]
    bin_size = 5 # ms
    bins = collect(1:bin_size:maximum(times))
    markersize=0.001#ms
    l = @layout [a ; b]
    p1 = scatter(times,nodes;bin=bins,label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.015, legend = false)
    p2 = plot(stephist(times, title="PSTH", legend = false))
    size_ = (800,600)

    Plots.plot(p1, p2, layout = l,size=size_)
    savefig("PSTH.png")

end
using ProgressMeter
using StatsPlots

function corrplot(nodes,times)
    #data = []
    #@inbounds for n in 1:length(nodes)#25#size(nodes)[1]
    #    xx = findall(x -> x == n, nodes)
    #    append!(data,times[xx])
    #end
    #data = data'[:]

    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end
    #w = exp.(xs)
    @show(size(xs))
    #d = sample(data'[:],200)
    #bin_size = 5 # ms
    #histogram2d(d,nbins= 40)|>display#,bins=bins)
    #xs = xs'[:]
    #h#eatmap(xs,ys) |>display
    #istogram2d(xs,nbins= maximum(unique(nodes)),show_empty_bins=true, normalize=:pdf,color=:inferno)|>display#,bins=bins)
    StatsPlots.corrplot([xs])|>display
    #@show(weights_)
    #return weights_

end
#corrplot(nodes,times)
#PSTHMap(nodes,times)
#StatsPlots.marginalhist
function PSTHMap0(nodes,times)
    #data = []
    #@inbounds for n in 1:length(nodes)#25#size(nodes)[1]
    #    xx = findall(x -> x == n, nodes)
    #    append!(data,times[xx])
    #end
    #data = data'[:]

    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end
    #w = exp.(xs)

    #d = sample(data'[:],200)
    #bin_size = 5 # ms
    #histogram2d(d,nbins= 40)|>display#,bins=bins)
    #xs = xs'[:]
    #h#eatmap(xs,ys) |>display
    #histogram2d(xs,nbins= maximum(unique(nodes)),show_empty_bins=true, normalize=:pdf,color=:inferno)|>display#,bins=bins)
    StatsPlots.marginalhist(xs)|>display
    #@show(weights_)
    #return weights_

end
function PSTHMap1(nodes,times)
    """
    currently the most functional
    """
    #data = []
    #@inbounds for n in 1:length(nodes)#25#size(nodes)[1]
    #    xx = findall(x -> x == n, nodes)
    #    append!(data,times[xx])
    #end
    #data = data'[:]

    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end
    #w = exp.(xs)

    #d = sample(data'[:],200)
    #bin_size = 5 # ms
    #histogram2d(d,nbins= 40)|>display#,bins=bins)
    #xs = xs'[:]
    #h#eatmap(xs,ys) |>display
    result = histogram2d(xs,nbins= Int(round(maximum(unique(nodes))/6.0)),show_empty_bins=true, normalize=:pdf,color=:inferno)#,bins=bins)
    #result = histogram2d(xs,show_empty_bins=true, normalize=:pdf,color=:inferno)#,bins=bins)

    #@show(result)
    result |>display
    #@StatsPlots.marginalhist(xs)|>display
    #@show(weights_)
    #return weights_

end
PSTH0(nodes,times) |> display

PSTHMap0(nodes,times)
PSTHMap1(nodes,times)

using StatsBase, StatsPlots, Distributions

function custom_histogram(nodes,times)
    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end

    timess_cat = hcat(xs)
    #ps = Union{Plot,Context}[]
    #for ci=1:nneurons
    
    mindt = 10.0
    stimes = sort(times)

    ##
    # find the smallest distance between spike times
    ##
    for i in 1:length(stimes)
        if i<length(stimes)
            newdt = stimes[i+1] - stimes[i] 
            if newdt < mindt && newdt !=0.0
                mindt = newdt
            end
        end
    end
    #list
    #data = Matrix{Float64}(undef, ns, Int(round(array_size)))
    weights = []
    #for ci=1:length(nodes)
    #    append!(weights,[])
    #end
    for ci=1:length(nodes)
        temp_vec = collect(mindt:Float32(maximum(stimes/200.0)):maximum(stimes))
        psth = fit(Histogram, vec(timess_cat[ci,:]),temp_vec)
        #@show(psth)
        if length(psth.weights)>1 
            #@show(psth.weights[:]) 
            println(length(psth.weights[:])) 
            append!(weights,psth.weights[:])
            println(maximum(nodes))
            
        end
        #@show(psth.weights)
    end
    @show(weights)
    histogram2d(weights)
        #               Param.stim_off : Param.learn_every : Param.train_time)
    #@show(mindt)
    ##
    # make a binary string
    ## 

    #=
    array_size = maximum(stimes)
    ns = maximum(nodes)+1
    data = Matrix{Float64}(undef, ns, Int(round(array_size)))


    crude_approx = array_size/1000.0
    #data = Matrix(Float32,(ns,Int(round(array_size/mindt))))
    for ci=1:length(nodes)
        spiket = times[ci]
        for (cnt,dt) in enumerate(crude_approx:crude_approx:maximum(stimes))
            if dt >= spiket && spiket< dt+crude_approxfor ci=1:length(nodes)
    
        psth = fit(Histogram, vec(timess_cat[ci,:]),
                   Param.stim_off : Param.learn_every : Param.train_time)
        #@show(data)
        #@show(maximum(data))
     
    end
    =#
    #for ci=1:length(nodes)
        
        #push!(data[ci], times[ci])
        #push!(ys, ci)
    #end 
    # Example data 
    #data = (randn(10_000), randn(10_000))
    
    # Plot StatsPlots 2D histogram
    histogram2d(data)
    
    # Fit a histogram with StatsBase
    h = fit(Histogram, data)
    x = searchsortedfirst(h.edges[1], 0.1)  # returns 10
    y = searchsortedfirst(h.edges[2], 0.1)  # returns 11
    h.weights[x, y] # returns 243
    
    # Or as a function
    function get_freq(h, xval, yval)
        x = searchsortedfirst(h.edges[1], xval)
        y = searchsortedfirst(h.edges[2], yval)
        h.weights[x, y]
    end
    
    get_freq(h, 1.4, 0.6) # returns 32


end
custom_histogram(nodes,times)

function _make_hist{N}(vs::NTuple{N,AbstractVector}, binning; normed = false, weights = nothing)
    # https://github.com/JuliaPlots/Plots.jl/blob/d6e5b57a089ba236c7df4d1ba1d20669bf809ad3/src/recipes.jl#L582
    edges = _hist_edges(vs, binning)
    h = float( weights == nothing ?
        StatsBase.fit(StatsBase.Histogram, vs, edges, closed = :left) :
        StatsBase.fit(StatsBase.Histogram, vs, weights, edges, closed = :left)
    )
    normalize!(h, mode = _hist_norm_mode(normed))
end

#@recipe 
function f(::Type{Val{:bins2d}}, x, y, z)
    edge_x, edge_y, weights = x, y, z.surf

    float_weights = float(weights)
    if float_weights === weights
        float_weights = deepcopy(float_weights)
    end
    for (i, c) in enumerate(float_weights)
        if c == 0
            float_weights[i] = NaN
        end
    end

    x := Plots._bin_centers(edge_x)
    y := Plots._bin_centers(edge_y)
    z := Surface(float_weights)

    match_dimensions := true
    seriestype := :heatmap
    ()
end
Plots.@deps bins2d heatmap


#@recipe 
function f(::Type{Val{:histogram2d}}, x, y, z)
    h = _make_hist((x, y), d[:bins], normed = d[:normalize], weights = d[:weights])
    x := h.edges[1]
    y := h.edges[2]
    z := Surface(h.weights)
    seriestype := :bins2d
    ()
end
#@deps histogram2d bins2d

#heatmap(weights)|>display
#PSTH(nodes,times)


