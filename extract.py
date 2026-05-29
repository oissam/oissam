import os

with open('lib/screens/call_center/cc_dashboard.dart', 'r') as f:
    lines = f.read().splitlines()

imports = [
    "import 'package:flutter/material.dart';",
    "import 'package:google_fonts/google_fonts.dart';",
    "import '../models/models.dart';",
    "import '../theme/app_theme.dart';",
    "import 'shared_widgets.dart';",
    "",
]

with open('lib/widgets/student_profile_dialog.dart', 'w') as f:
    f.write('\n'.join(imports + lines[7:363]))
