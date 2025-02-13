using HDF5
using Plots
using Random
using Revise
using ProgressMeter
using StatsPlots
using UMAP
using StatsBase, StatsPlots, Distributions
using MultivariateStats






hf5 = h5open("spikes.h5","r")
nodes = Vector{Int64}(read(hf5["spikes"]["v1"]["node_ids"]))
times = Vector{Float64}(read(hf5["spikes"]["v1"]["timestamps"]))
close(hf5)
#println("gets here a")
function raster(nodes,times)
    xs = []
    ys = []
    for ci=1:length(nodes)
        push!(xs, times[ci])
        push!(ys, ci)
    end
    size = (800,600)
    p0 = Plots.plot(;size,leg=false,title="spike train",grid=false)
    scatter(p0,xs,ys;label="SpikeTrain",markershape=:vline,markersize=ms,mc="black",markerstrokewidth = 0.5)
    savefig("Better_Spike_Rastery.png")
end

function raster(nodes,times)

    #=
    Don't forget to make a normalized raster plot
    =#
    size = (800,600)
    p0 = Plots.plot(;size,leg=false,title="spike train",grid=false)
    markersize=0.0001#ms
    scatter(p0,times,nodes;label="SpikeTrain",markershape=:vline,mc="black",markerstrokewidth = 0.00015)
    savefig("Better_Spike_Rastery.png")
end


function PSTH0(nodes,times)
    temp = size(nodes)[1]
    bin_size = 5 # ms
    bins = collect(1:bin_size:temp)
    markersize=0.001#ms
    l = @layout [a ; b]
    p1 = scatter(times,nodes;bin=bins,label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.015,mc="black", legend = false)
    p2 = plot(stephist(times, title="PSTH", legend = false))
    size_ = (800,600)
    Plots.plot(p1, p2, layout = l,size=size_) 
    savefig("PSTH.png")

    #savefig("PSTH.png")

end
#=
function PSTH(nodes,times)
    #temp = size(nodes)[1]
    bin_size = 55 # ms
    bins = collect(1:bin_size:maximum(times))
    markersize=0.001#ms
    l = @layout [a ; b]
    p1 = scatter(times,nodes;bin=bins,label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.015, legend = false)
    p2 = plot(stephist(times, title="PSTH", legend = false))
    size_ = (800,600)

    Plots.plot(p1, p2, layout = l,size=size_)
    savefig("PSTH.png")

end
=#

function filter(nodes,times)
    n_ = []
    t_ = []
    for (i,j) in zip(nodes,times)
        if i <= 50
            append!(n_,i)
            append!(t_,j)

        end
    end
    l = @layout [a ; b]
    bin_size = 105 # ms
    bins = collect(1:bin_size:maximum(times))
    markersize=0.001#ms
    p1 = scatter(t_,n_,label="SpikeTrain",markershape=:vline,markerstrokewidth = 0.015, legend = false)
    p2 = plot(stephist(times, title="PSTH", legend = false))
    size_ = (800,600)

    Plots.plot(p1, p2, layout = l,size=size_)
    savefig("PSTH_reduced.png")
    return (n_,t_)
end

function bespoke_umap(data)
    #=
    stimes = sort(times)
    ns = maximum(unique(nodes))
    temp_vec = collect(0:Float64(round(maximum(stimes)/nbins)):maximum(stimes))
    templ = []
    for (cnt,n) in enumerate(unique(nodes))
        push!(templ,[])
    end
    for (cnt,n) in enumerate(nodes)
        push!(templ[n+1],times[cnt])    
    end
    data = Matrix{Float64}(undef, ns+1, Int(length(temp_vec)-1))
    for (ind,t) in enumerate(templ)
        psth = fit(Histogram,t,temp_vec)
        data[ind,:] = psth.weights[:]
    end
    =#
    ##
    # Assuming 3 EEG
    ##
    #n_components = 3
    res_jl = umap(data,n_neighbors=3, min_dist=0.001, n_epochs=450)
    Plots.plot(scatter(res_jl[1,:], res_jl[2,:], title="Spike Rate: UMAP", marker=(2, 2, :auto, stroke(0.0005))))# |> display
    Plots.savefig("UMAP_for_pabloxx.png")
    data = data'[:,:]
    res_jl = umap(data,n_neighbors=3, min_dist=0.001, n_epochs=450)
    Plots.plot(scatter(res_jl[1,:], res_jl[2,:], title="Spike Rate: UMAP", marker=(2, 2, :auto, stroke(0.0005))))# |> display
    Plots.savefig("UMAP_for_pablo_transpose.png")
    return data,res_jl
end
function bespoke_PCA(data)
    #=
    stimes = sort(times)
    ns = maximum(unique(nodes))
    temp_vec = collect(0:Float64(round(maximum(stimes)/nbins)):maximum(stimes))
    templ = []
    for (cnt,n) in enumerate(unique(nodes))
        push!(templ,[])
    end
    for (cnt,n) in enumerate(nodes)
        push!(templ[n+1],times[cnt])    
    end
    data = Matrix{Float64}(undef, ns+1, Int(length(temp_vec)-1))
    for (ind,t) in enumerate(templ)
        psth = fit(Histogram,t,temp_vec)
        data[ind,:] = psth.weights[:]
    end
    =#
    # Assuming 3 EEG
    ##
    #n_components = 3
    data = data'[:,:]
    M = fit(PCA, data; maxoutdim=3)
    Yte = predict(M, data)
    p = scatter(Yte[1,:],Yte[2,:], marker=(2, 2, :auto, stroke(0.0005)))
    plot!(p,xlabel="PC1",ylabel="PC2")
    Plots.savefig("PCA_for_pablo0.png")
    p = scatter(Yte[2,:],Yte[3,:], marker=(2, 2, :auto, stroke(0.0005)))
    plot!(p,xlabel="PC2",ylabel="PC3")
    Plots.savefig("PCA_for_pablo1.png")
    p = scatter(Yte[2,:],Yte[3,:],Yte[1,:], marker=(2, 2, :auto, stroke(0.0005)))
    plot!(p,xlabel="PC2",ylabel="PC3",zlabel="PC3")
    Plots.savefig("PCA_for_pablo2.png")
    return data,Yte
end

function bespoke_2dhist(nbins,nodes,times,fname=nothing)
    stimes = sort(times)
    ns = maximum(unique(nodes))    
    temp_vec = collect(0:Float64(maximum(stimes)/nbins):maximum(stimes))
    templ = []
    for (cnt,n) in enumerate(collect(1:maximum(nodes)+1))
        push!(templ,[])
    end
    for (cnt,n) in enumerate(nodes)

        push!(templ[n+1],times[cnt])    
        #@show(templ[n+1])
    end
    data = sparse(Matrix{Float64}(undef, ns+1, Int(length(temp_vec)-1)))
    for (ind,t) in enumerate(templ)
        psth = fit(Histogram,t,temp_vec)
        data[ind,:] = psth.weights[:]
    end
    #data = sparse(data)
    return data
end


function normalised_2dhist(data)

    data = data[:,:]./maximum(data[:,:])
    return data
end
#println("Delayed y")

#(n_,t_) = filter(nodes,times)
PSTH0(nodes,times) 
nbins = 425.0
#nbins = 1425.0
data = bespoke_2dhist(nbins,nodes,times)
datan = normalised_2dhist(data)

@code_typed normalised_2dhist(data)
@lower normalised_2dhist(data)

Plots.plot(heatmap(datan),legend = false, normalize=:pdf)
Plots.savefig("heatmap_normalised.png")
#println(varinfo())

nbins = 1425.0
data = bespoke_2dhist(nbins,nodes,times)
_,res_jl = bespoke_umap(data)
Plots.plot(heatmap(data),legend = false, normalize=:pdf)
Plots.savefig("detailed_heatmap.png")

#nbins = 1425.0
#nbins = 2425.0
#nbins = 1425.0
#nbins = 1425.0
#nbins = 325.0

nbins = 100

data = bespoke_2dhist(nbins,nodes,times)
#println("Delayed 2")

data,res_jl = bespoke_PCA(data)

function corrplot_(data)
    StatsPlots.corrplot(data[1:5,1:5], grid = false, compact=true)
    savefig("corrplot.png")
end
function slow_to_exec(data,nbins)

    corrplot_(data)
    
    #=
    data = data'[:,:]

    StatsPlots.histogram2d(data,show_empty_bins=true, normalize=:pdf,color=:inferno)#,bins=bins)
    Plots.savefig("detailed_hist_map.png")
    StatsPlots.marginalhist(data,show_empty_bins=true, normalize=:pdf,color=:inferno)#,bins=bins)
    Plots.savefig("marginal_kde_detailed_hist_map.png")
    StatsPlots.marginalkde(data,show_empty_bins=true, normalize=:pdf,color=:inferno)#,bins=bins)
    Plots.savefig("marginal_ruggs_detailed_hist_map.png")
    =#
end
nbins = 425.0
data = bespoke_2dhist(nbins,nodes,times)
slow_to_exec(data,nbins)
