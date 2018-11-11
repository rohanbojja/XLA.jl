using XLA
using TensorFlow
using Test

xrt_server_process = run(`$(joinpath(dirname(pathof(TensorFlow)),"..","deps","downloads","bin","xrt_server"))`; wait=false)
sess = Session(Graph(); target="grpc://localhost:8470")
try
    # Issue #5
    f() = XLA.HloRng(Float32, (5,5), 1)(XRTArray(0f0),XRTArray(1f0))
    @test isa(begin
        run(@tpu_compile f())
    end, XRTArray)
finally
    GC.gc() # Try running finalizers, before the process exits
    close(sess)
    kill(xrt_server_process)
end
