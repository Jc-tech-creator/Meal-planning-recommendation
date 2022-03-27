# Meal-planning-recommendation
In general, We built a recommendation system that can generate meal plans for small groups based on users’ rating predictions and constraints, using code of Python and Julia. In this example, we generate one- week meal plan for a group of four

The first file is a python file, it is to apply matrix completion technique (Matrix Factorization) to complete the rating prediction matrix using Python

The second file is a julia code, it is to construct a Mixed Integer Programming (MIP) model with Julia code to maximize the sum of ratings based on predicted rating matrix and meet constraints of dishes Arrangement, nutrients requirements, budgets, available cooking time
