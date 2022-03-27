# import DelimitedFiles 
using DelimitedFiles
# Import calories data
calories = readdlm("C:\\Users\\13829\\Desktop\\ISE 533\\Project 2\\calories.csv")
fat = readdlm("C:\\Users\\13829\\Desktop\\ISE 533\\Project 2\\fat.csv")
protein = readdlm("C:\\Users\\13829\\Desktop\\ISE 533\\Project 2\\protein.csv")
sodium = readdlm("C:\\Users\\13829\\Desktop\\ISE 533\\Project 2\\sodium.csv")
price = rand(6:20,256)


df = readdlm("C:\\Users\\13829\\Desktop\\ISE 533\\Project 2\\pj2.csv")
df1=df[2885:2888,:]

# import Pkg; Pkg.add("JuMP"); Pkg.add("GLPK")
using JuMP, GLPK

# Create the MCP model to maximize the population reached in Ohio
# We use GLPK as the solver
# Model for 2011 data
model = Model(GLPK.Optimizer)
set_silent(model)

# Variables definition
@variable(model, x[1:5,1:256], Bin)
# Recommend one dish for each meal

for i in 1:5
    @constraint(model,sum(x[i,t] for t in 1:256)==1)
end

# Ensure that each dish only appear once in our recommendation
for t in 1:256
    @constraint(model,
    sum(x[i,t] for i in 1:5)<=1)
end

for i in 1:5
#calories:or From 1,600 to 2,400 calories per day for women and 2,000 to 3,000 calories a day for men.
# For our group, we have 2 women and 2 men
    @constraint(model,sum(x[i,t]*calories[t] for t in 1:256)<=1000)
    @constraint(model,sum(x[i,t]*calories[t] for t in 1:256)>=400)

# A high fat intake is more than 35 percent of your calories, while a low intake is less than 20 percent.
# We have a lower bound and upper bound for fat

    @constraint(model,sum(x[i,t]*fat[t] for t in 1:256)>=44/3)
    @constraint(model,sum(x[i,t]*fat[t] for t in 1:256)<=77/3)

# The sodium RDI is less than 2,300 milligrams per day for adults
    @constraint(model,sum(x[i,t]*sodium[t] for t in 1:256)<=2300/3)

#the protein is between 50 and 175 for an adult per day
    @constraint(model,sum(x[i,t]*protein[t] for t in 1:256)>=50/3)
    @constraint(model,sum(x[i,t]*protein[t] for t in 1:256)<=175/3)

#our budget per person per day is 30 dollars
    @constraint(model,sum(x[i,t]*price[t] for t in 1:256)<=20)
end


@objective(model, Max, sum(x[i,t]*
(sum(df1[i,t] for i in 1:4))
for i in 1:5 for t in 1:256))


# call optimizer
optimize!(model)

# Show results
@show objective_value(model)
x = value.(x)

# Specific meal plan
for i in 1:5
     for t in 1:256
        if(x[i,t]==1)
            print(i)
            print(" ")
            print(" ")
            print(t)
            print(" ")
            println()
        end
    end
end

df1[1:4,203]
df1[1:4,229]
df1[1:4,130]
df1[1:4,146]
df1[1:4,143]

# Fat
y=0
for i in 1:5
        for t in 1:256
            y=y+x[i,t]*fat[t]
        end
    end
y

# Budget
budg=0
for i in 1:5
        for t in 1:256
            budg=budg+x[i,t]*price[t]
        end
    end
budg

# The second model for cooking time

# Time matrix
time1 = [[0,0,0,0,1],
[1,0,1,0,1],
[1,0,1,0,1],
[0,1,1,1,1]]

avail=[0.0,0.0,0.0,0.0]
for i in 1:4
    for j in 1:5
        avail[i]=avail[i]+time1[i][j]
    end
end
avail

function check_index(a,i)
    for t in 1:length(a)
        if(a[t]==i)
            return false
        end
    end
    return true
end

#rank user time availability with their index
rank=[-1,-1,-1,-1]
function ranking(rank,avail)
    for i in 1:4
        min=999
        for j in 1:4
            if(check_index(rank,j))
                if(avail[j]<min)
                    rank[i]=j
                    min=avail[j]
                end
            end
        end
    end
    return rank
end
rank=ranking(rank,avail)      


for i in 1:4
    avail[i]=1-avail[i]/5.00
end
avail


# Variable definition
function check(time)
    for j in 1:5
        sum=0
        for i in 1:4
            sum=sum+time1[i][j]
            end
            if(sum==0)
                print("Please reschedule")
                return;
        end
    end
    print("Time schedule is OK")
end

check(time)

model1 = Model(GLPK.Optimizer)
set_silent(model1)

# Variables definition
@variable(model1, deci[1:4,1:5], Bin)
@variable(model1, s[1:4])
#to ensure there is someone cooking for each dinner
for j in 1:5
    @constraint(model1,sum(deci[i,j]  for i in 1:4)==1)
end


#to ensure members with more time do more cooking
for i in 1:3
    t1=rank[i]
    t2=rank[i+1]
    @constraint(model1,sum(deci[t1,j]  for j in 1:5)<=sum(deci[t2,j]  for j in 1:5))
end


#To make sure the member is available to cook for that dinner
for j in 1:5
    for i in 1:4
    @constraint(model1,deci[i,j]<=time1[i][j])
    end
end
@objective(model1, Max, sum(avail[i]*
    sum(deci[i,j] for j in 1:5) for i in 1:4))
optimize!(model1)
@show objective_value(model1)
deci1 = value.(deci)

