
class AttackType {
  static melee { "basic" }
  static lightning { "lightning" }

  static verify(text) {
    if (text == "basic" ||
      text == "lightning") {
      return text
    }
    Fiber.abort("unknown AttackType: %(text)")
  }
}

class Attack {
  construct new(damage, attackType, needsMana) {
    _damage = damage
    _attackType = AttackType.verify(attackType)
    _needsMana = needsMana
  }

  damage { _damage }
  attackType { _attackType }
  needsMana { _needsMana }

  static melee(entity) {
    return Attack.new(entity["stats"].get("atk"), AttackType.melee, true)
  }
}
