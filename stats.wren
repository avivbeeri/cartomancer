class StatGroup {
  construct new(statMap) {
    _base = statMap
    _mods = {}
  }

  addModifier(mod) {
    _mods[mod.id] = mod
  }

  removeModifier(id) {
    _mods.remove(id)
  }

  base(stat) { _base[stat] }
  set(stat, value) { _base[stat] = value }

  get(stat) {
    var value = _base[stat]
    var multiplier = 0
    var total = value || 0
    for (mod in _mods.values) {
      total = total + (mod.add[stat] || 0)
      multiplier = multiplier + (mod.mult[stat] || 0)
    }
    return total + total * multiplier
  }

  print(stat) {
    return "%(stat)>%(base(stat)):%(get(stat))"
  }
}

/**
  Represent arbitrary modifiers to multiple stats at once
  Modifiers can be additive or multiplicative.
  Multipliers are a "percentage change", so +0.5 adds 50% of base to the value.
*/
class Modifier {
  construct new(id, add, mult) {
    _id = id
    _add = add || {}
    _mult = mult || {}
  }

  id { _id }
  add { _add }
  mult { _mult }
}

