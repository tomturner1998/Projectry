enum Role { Student, Supervisor }

Role roleFromString(String roleString) {
  Role role;
  Role.values.forEach((element) {
    if (element.toString().toLowerCase() == roleString.toLowerCase()) {
      role = element;
    }
  });

  return role;
}
