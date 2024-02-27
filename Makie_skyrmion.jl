using LinearAlgebra, GLMakie,GeometryBasics,Colors

struct Param
    r_min::Float64 # position of spins next origin
    r_max::Float64 # position of spins the most distant from origin
    num_radius::Int64 # number of spins aligned in radius direction
    num_angle::Int64 # maximum number of spins aligned in angular direction
end


function get_position(P::Param)
    r = range(P.r_min,P.r_max,length=P.num_radius)
    

    ρ = 2.0*pi*P.r_max/P.num_angle



    position = Vector{Float64}[]
    push!(position,Float64[0.0,0.0,0.0])
    for i in 1:P.num_radius
        n_θ = round(Int64,2.0*pi*r[i]/ρ)
        θ = range(0.0,2*pi,length=n_θ)
        for j in 1:n_θ
            x = r[i]*cos(θ[j])
            y = r[i]*sin(θ[j])
            push!(position,Float64[x,y,0.0])
        end
    end

    return position
end



function create_angle_spins(pos_data,Name)
    r = norm.(pos_data)
    r_norm = r./maximum(r)
    angle_z = pi.*r_norm

    if Name == "Bloch"
        θ_p = 0.0
    elseif Name == "Neel"
        θ_p = pi/2
    else
        error("Name is must be string(Nell) or string(Bloch)")
    end

    w = cos.(angle_z)

    r_inplane = sin.(angle_z)

    direction = Vector{Float64}[]
    w_data = Float64[]
    for i in 1:length(r)
        θ = angle(pos_data[i][1] + im*pos_data[i][2])+θ_p
        
        u = r_inplane[i]*cos(θ)
        v = r_inplane[i]*sin(θ)

        push!(direction,Float64[u,v,w[i]])
        push!(w_data,r_norm[i])
    end
    
    return direction,w_data
end



function plot_skyrmion(r_min,r_max,num_radius,num_angle,Name)

    P = Param(r_min,r_max,num_radius,num_angle)

    pos = get_position(P)
    dir,colors = create_angle_spins(pos,Name)
    println(size(pos))
    println(size(dir))
    
    position = [Point3f(i) for i in pos]
    direction = [Point3f(i) for i in dir] 

    fig = Figure(resolution=(720, 720), dpi=600)
    ax = Axis3(fig[1,1], aspect=:data, perspectiveness=0.6,
                azimuth = 0.2 * pi,elevation = pi/2)
    dence = (P.r_max-P.r_min)/P.num_radius
    scale_arrow = dence*0.6
    s_a = Vec3f0(scale_arrow,scale_arrow,scale_arrow) 
    cl = HSV.(colors*240, 50, 50)
    
    arrows!(ax, position, direction,          # axes, positions, directions
            linecolor=cl,
            arrowcolor=cl, 
            quality=32,                          # Sets the quaity of the arrow.
            arrowsize=s_a,   # Scales the size of the arrow head. 
            linewidth=dence*0.2, 
            align=:center,)                      # Sets how arrows are positioned.

    # vanish the back ground
    hidedecorations!(ax)
    hidespines!(ax)
    fig

    #save("skyrmion.png",fig)
end




plot_skyrmion(2.0,10.0,10,40,"Bloch")