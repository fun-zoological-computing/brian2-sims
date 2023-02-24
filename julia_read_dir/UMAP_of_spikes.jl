
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
