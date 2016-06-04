# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :letter do
    to_address {
      %|Dr. #{(COMMON_BOY_NAMES + COMMON_GIRL_NAMES).sample} #{COMMON_SURNAMES.sample} (#{SPECIALTIES.sample})
4709 30 Street
Lloydminster, SK
S9V 1E1|
    }
    patient { patient }
    creator { user }
    signed_off_at { updated_at + rand(1.second..1.hour) }
    state { 'signed_off' }
    created_at { rand(5.years.ago..1.day.ago) }
    updated_at { created_at }
    content { "Dear #{to_address.split("\n")[0]},\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus porta in tellus sit amet lacinia. Integer et est ut odio semper feugiat. Vivamus nec auctor nibh. Quisque scelerisque ornare urna, non vulputate elit. Sed magna felis, elementum vel accumsan accumsan, fringilla vitae magna. In hac habitasse platea dictumst. Praesent pharetra euismod consequat. Praesent gravida neque id nibh placerat, accumsan pellentesque nisi tristique. Cras eu mauris a nunc gravida lobortis ac bibendum neque. Praesent commodo pulvinar enim. Proin nisl quam, imperdiet ac bibendum porta, porttitor ac erat. Cras volutpat laoreet nisl, eu molestie libero rhoncus in. Vestibulum mi purus, tincidunt eget sapien eget, convallis congue elit.\n\nNullam porttitor at mauris eget sodales. Cras tortor magna, aliquet et convallis ac, hendrerit eu libero. Nunc sed justo mollis, viverra massa et, ultrices nulla. Curabitur luctus ultricies dui lacinia tempor. Phasellus eu tempor nisi, a scelerisque leo. Phasellus sagittis risus quis egestas porta. Ut sodales, augue non vehicula sodales, mauris augue varius turpis, et feugiat enim felis at quam.\n\nPhasellus eu lobortis elit. Donec tempor est at ipsum tincidunt placerat. Curabitur ultricies dui in mi rutrum, ac rhoncus risus condimentum. Curabitur eget porta purus. Nam sollicitudin dignissim diam, ut porttitor dolor laoreet id. Quisque ultricies pharetra elementum. Sed commodo nulla in placerat lacinia.\n\nNam condimentum adipiscing quam, id blandit felis facilisis sit amet. Aenean sagittis cursus ornare. Mauris interdum odio diam, et pellentesque metus ornare non. Mauris id erat nunc. Vestibulum aliquet ante eros, nec porta magna tincidunt eleifend. Fusce pulvinar dolor a luctus fermentum. Cras laoreet est vitae ultricies lacinia. Vivamus ultricies eget lorem quis pharetra. Vivamus in metus eget tortor iaculis iaculis ac a massa. Morbi pharetra felis ac pulvinar eleifend. Suspendisse dictum in velit eget laoreet.\n\nUt nec magna luctus, pulvinar lacus vel, cursus felis. In molestie sed urna ac dignissim. Donec hendrerit, odio quis mollis euismod, lacus ipsum faucibus lacus, nec pretium tortor arcu sed lacus. Vivamus eu turpis vitae ante scelerisque cursus. Proin laoreet nisi vel tellus feugiat tristique. Duis at nulla eget mi fringilla convallis. Pellentesque ornare diam augue, nec suscipit felis bibendum at. Duis porttitor justo ipsum, sed lacinia eros egestas in. Morbi tortor nisl, semper eget commodo id, commodo eget augue. Morbi sit amet eros nec sapien tincidunt pharetra. Ut rutrum a quam id placerat.\n\nKind regards,\n<signature>\n#{creator.full_name_with_title}" }
  end
end
