// Recipe database for RM Insta Depo
export interface Recipe {
  name: string
  materials: string
  category?: string
}

const recipes: Recipe[] = [
  { name: "Aloe Goo Bomb", materials: "6 Aloe Gel, 6 Cotton, 2 Rope", category: "Utility" },
  { name: "Ammo Chest", materials: "12 Wood Shaft, 20 Stone, 40 Fiber, 25 Wood", category: "Storage" },
  { name: "Advanced Capital Walker Wing", materials: "40 Lightwood, 27 Hollowbone, 22 Nomad Cloth", category: "Walker Parts" },
  { name: "Advanced Fiberworking Station", materials: "35 Wood, 8 Nurr Fang, 35 Fiber Weave, 12 Wood Shaft", category: "Crafting" },
  { name: "Advanced Furnace", materials: "25 Iron Gear, 10 Shardrock, 12 Gelatinous Goo, 100 Lightwood", category: "Crafting" },
  { name: "Advanced Stomping Station", materials: "85 Redwood Wood, 90 Stone, 32 Wood Shaft, 15 Clay, 24 Rope", category: "Crafting" },
  { name: "Aloe Gel", materials: "5 Aloe Vera", category: "Materials" },
  { name: "Ancient Repair Hammer", materials: "100 Bone Splinter, 50 Hide", category: "Tools" },
  { name: "Apple Kambaro", materials: "3 Apple", category: "Food" },
  { name: "Armored Capital Walker Leg", materials: "32 Lightwood, 22 Iron Ore, 15 Shardrock", category: "Walker Parts" },
  { name: "Armored Medium Walker Leg", materials: "12 Redwood Wood, 23 Earth Wax, 17 Bone Splinter", category: "Walker Parts" },
  { name: "Anti-Personnel Turret", materials: "60 Wood, 7 Rope, 5 Fiber Weave", category: "Defense" },
  { name: "Balaclava", materials: "12 Fiber", category: "Armor" },
  { name: "Base Container", materials: "375 Wood, 80 Stone, 185 Fiber, 15 Nomad Cloth, 20 Rupu Vine, 20 Wood Shaft, 5 Beeswax", category: "Storage" },
  { name: "Base Maintenance Chest", materials: "130 Wood, 150 Fiber, 25 Stone, 12 Rope", category: "Storage" },
  { name: "Ballista", materials: "24 Wood, 5 Fiber Weave, 5 Wood Shaft", category: "Defense" },
  { name: "Bone Bolt", materials: "5 Wood Shaft, 5 Bone Splinter, 12 Fiber", category: "Ammunition" },
  { name: "Bone Scattershot Ammo", materials: "8 Bone Splinter, 3 Fiber Weave", category: "Ammunition" },
  { name: "Baskwood Armor", materials: "20 Tree Sap, 7 Leather", category: "Armor" },
  { name: "Baskwood Boots", materials: "10 Tree Sap, 2 Leather", category: "Armor" },
  { name: "Baskwood Bracers", materials: "8 Rupu Vine, 1 Leather", category: "Armor" },
  { name: "Blacksmith Station", materials: "15 Nibiran Ingot, 10 Worm Scale, 115 Lightwood, 12 Shardrock", category: "Crafting" },
  { name: "Ceramic Shard", materials: "3 Clay", category: "Materials" },
  { name: "Chitin Plate", materials: "6 Chitin", category: "Materials" },
  { name: "Cotton", materials: "3 Rupu Vine", category: "Materials" },
  { name: "Fiber Weave", materials: "5 Fiber", category: "Materials" },
  { name: "Iron Ingot", materials: "2 Iron Ore", category: "Materials" },
  { name: "Leather", materials: "4 Hide", category: "Materials" },
  { name: "Nomad Cloth", materials: "4 Cotton", category: "Materials" },
  { name: "Rope", materials: "3 Fiber", category: "Materials" },
  { name: "Stone", materials: "1 Rock", category: "Materials" },
  { name: "Wood Shaft", materials: "2 Wood", category: "Materials" },
  { name: "Wooden Gear", materials: "8 Wood, 4 Fiber", category: "Materials" },
]

export function searchRecipes(query: string): Recipe[] {
  if (!query || query.trim().length === 0) {
    return []
  }

  const lowerQuery = query.toLowerCase().trim()

  return recipes.filter(recipe =>
    recipe.name.toLowerCase().includes(lowerQuery) ||
    recipe.materials.toLowerCase().includes(lowerQuery) ||
    (recipe.category && recipe.category.toLowerCase().includes(lowerQuery))
  ).slice(0, 20) // Limit to 20 results
}

export function getAllRecipes(): Recipe[] {
  return recipes
}

export function getRecipeByName(name: string): Recipe | undefined {
  return recipes.find(recipe =>
    recipe.name.toLowerCase() === name.toLowerCase()
  )
}
