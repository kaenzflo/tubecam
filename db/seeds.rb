# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


users = [
    ['user1','Peter','Spotter',true,false,false,false,true,'user1@example.com', ENV['DATABASE_SEED_USER_PWD']],
    ['user2','Peter','Verified',true,true,false,false,true,'user2@example.com',ENV['DATABASE_SEED_USER_PWD']],
    ['user3','Peter','Trapper',true,true,true,false,true,'user3@example.com',ENV['DATABASE_SEED_USER_PWD']],
    ['user4','Hans','Trapper',true,true,true,false,true,'user4@example.com',ENV['DATABASE_SEED_USER_PWD']],
    ['admin','Peter','Admin',true,true,true,true,true,'admin@example.com',ENV['DATABASE_SEED_USER_PWD']]
]

users.each do |value|
  User.create(username: value[0],
              firstname: value[1],
              lastname: value[2],
              spotter_role: value[3],
              verified_spotter_role: value[4],
              trapper_role: value[5],
              admin_role: value[6],
              active: value[7],
              email: value[8],
              password: value[9])
end

tubecam_devices = [
    ['SN:00028',3,'Peters TubeCam',true],
    ['SN:00010',4,'Tubecam von Hans',true],
    ['SN:00014',4,'Tubecam2 von Hans',true],
    ['SN:00071',5,'Thurauen1 Flussbett',true],
    ['SN:00072',5,'Thurauen2 Nord',true],
    ['SN:00073',5,'Thurauen3 Weiher',true],
    ['SN:00074',5,'Thurauen4 Süd',true],
    ['SN:00075',5,'Thurauen5 Moor',true]
]

tubecam_devices.each do |value|
  TubecamDevice.create(serialnumber: value[0],
                       user_id: value[1],
                       description: value[2],
                       active: value[3])
end

media = [
    ['2017/02/28','SN00028_2017_02_28_18_26_44_S0031I19.jpg','f790923ff6cddb289da516b0bf97f31391f9ea69c08132d10aa2d2c38feae240.jpg','image',DateTime.strptime('2017:02:28 18:26:44', '%Y:%m:%d %H:%M:%S'),47.496503, 8.729533,31,19,1,nil,false],
    ['2016/02/09','SN00010_2016_02_09_17_17_31_S0001I05.jpg','ed46a607709409b6b30210aa7b65e8678244258d54950d3cc43c1aabc020734d.jpg','image',DateTime.strptime('2016:02:09 17:17:31', '%Y:%m:%d %H:%M:%S'),47.496611, 8.729497,1,5,2,nil,false]
]

media.each do |value|
  Medium.create(original_path: value[0],
                original_filename: value[1],
                filename_hash: value[2],
                mediatype: value[3],
                datetime: value[4],
                longitude: value[5],
                latitude: value[6],
                sequence: value[7],
                frame: value[8],
                tubecam_device_id: value[9],
                exifdata: value[10],
                deleted: value[11])
end

annotations_lookup_table = [
    ['100',nil,'Bilche',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['111','Gartenschläfer','Bilche','Eliomys','quercinus',true,100,170,90,125,220,320,true,false,true,true,false,true,false,true,true],
    ['121','Baumschläfer','Bilche','Dryomys','nitedula',true,80,130,80,95,190,240,true,false,true,true,false,true,false,true,true],
    ['131','Siebenschläfer','Bilche','Glis','glis',true,130,190,110,150,240,340,true,false,true,true,false,true,false,true,true],
    ['141','Haselmaus','Bilche','Muscardinus','avellanarius',true,60,90,55,75,150,185,true,false,false,true,false,true,false,true,true],
    ['200',nil,'Langschwanzmäuse',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['210',nil,nil,'Rattus',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['211','Hausratte','Langschwanzmäuse','Rattus','rattus',false,140,230,170,280,300,400,false,true,false,true,false,true,false,true,true],
    ['212','Wanderratte','Langschwanzmäuse','Rattus','norvegicus',false,190,270,160,229,380,450,false,true,false,true,false,true,false,true,true],
    ['221','Zwergmaus','Langschwanzmäuse','Micromys','minutus',true,58,76,51,72 ,130,160,false,true,false,true,false,true,false,true,true],
    ['220',nil,nil,'Apodemus',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['231','Gelbhalsmaus','Langschwanzmäuse','Apodemus','flavicollis',false,88,130,92,134,230,270,false,true,false,true,false,true,false,true,true],
    ['232','Waldmaus','Langschwanzmäuse','Apodemus','sylvaticus',false,77,110,69,115,200,250,false,true,false,true,false,true,false,true,true],
    ['233','Alpenwaldmaus','Langschwanzmäuse','Apodemus','alpicola',false,86,96,110,120,0,0,false,true,false,true,false,true,false,true,true],
    ['241','Hausmaus','Langschwanzmäuse','Mus','domesticus',true,75,103,72,102,165,195,false,true,false,true,false,true,false,true,false],
    ['300',nil,'Wühlmäuse',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['311','Schermaus','Wühlmäuse','Arvicola','terrestris',true,120,170,50,75,220,250,false,true,false,true,false,false,true,true,false],
    ['321','Rötelmaus','Wühlmäuse','Clethrionomys','glareolus',true,85,110,50,70,150,200,false,true,false,true,false,true,true,true,false],
    ['331','Schneemaus','Wühlmäuse','Chionomys','nivalis',true,100,130,56,76,185,220,false,true,false,true,false,true,true,true,false],
    ['340',nil,nil,'Microtus',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['341','Feldmaus','Wühlmäuse','Microtus','arvalis',false,90,120,24,45,150,185,false,true,false,true,false,false,true,true,false],
    ['342','Erdmaus','Wühlmäuse','Microtus','agrestis',false,95,133,35,46,160,205,false,true,false,true,false,false,true,true,false],
    ['350',nil,nil,'Microtus (Pitmys)',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['351','Fatio - Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','multiplex',false,90,110,40,44,150,160,false,true,false,true,false,false,true,true,false],
    ['352','Savi - Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','savii',false,90,100,22,30,130,150,false,true,false,true,false,false,true,true,false],
    ['353','Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','subterraneus',false,70,100,35,42,140,145,false,true,false,true,false,false,true,true,false],
    ['400',nil,'Hörnchen',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['411','Eichhörnchen','Hörnchen','Sciurus','vulgaris',true,200,250,150,200,520,620,true,false,false,false,true,true,false,true,false],
    ['500',nil,'Spitzmäuse',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['511','Feldspitzmaus','Spitzmäuse','Crocidura','leucodon',true,64,84,29,41,110,140,false,true,false,true,false,false,true,false,true],
    ['512','Gartenspitzmaus','Spitzmäuse','Crocidura','suaveolens',true,55,77,33,40,100,120,false,true,false,true,false,false,true,false,true],
    ['513','Hausspitzmaus','Spitzmäuse','Crocidura','russula',true,64,84,33,46,110,140,false,true,false,true,false,false,true,false,true],
    ['521','Wasserspitzmaus','Spitzmäuse','Neomys','fodiens',true,72,96,47,77,160,200,false,true,false,true,false,false,true,false,true],
    ['522','Sumpfspitzmaus','Spitzmäuse','Neomys','anomalus',true,64,88,42,64,140,170,false,true,false,true,false,false,true,false,true],
    ['530',nil,nil,'Sorex',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['531','Waldspitzmaus','Spitzmäuse','Sorex','araneus',false,66,88,30,57,100,145,false,true,false,true,false,false,true,false,true],
    ['532','Walliserspitzmaus','Spitzmäuse','Sorex','antinorii',false,54,82,40,60,0,0,false,true,false,true,false,false,true,false,true],
    ['533','Alpenspitzmaus','Spitzmäuse','Sorex','alpinus',false,62,87,60,76,140,160,false,true,false,true,false,false,true,false,true],
    ['534','Zwergspitzmaus','Spitzmäuse','Sorex','minutus',false,44,62,37,46,90,120,false,true,false,true,false,false,true,false,true],
    ['600',nil,'Igel',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['611','Westigel','Igel','Erinaceus','europaeus',true,250,300,25,30,400,470,true,true,false,true,false,false,true,false,true],
    ['700',nil,'Maulwürfe',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['710',nil,nil,'Talpa',nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['711','Blindmaulwurf','Maulwürfe','Talpa','caeca',false,106,123,27,39,160,180,true,true,false,true,false,false,true,false,true],
    ['712','Europäischer Maulwurf','Maulwürfe','Talpa','europaea',false,124,144,27,38,165,200,true,true,false,true,false,false,true,false,true],
    ['800',nil,'Marderartige',nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['811','Iltis','Marderartige','Mustela','putorius',true,280,450,100,170,470,700,true,false,true,false,true,true,false,true,true],
    ['812','Hermelin','Marderartige','Mustela','herminea',true,210,370,70,130,330,500,true,false,false,false,true,true,false,true,true],
    ['813','Mauswiesel','Marderartige','Mustela','nivalis',true,140,190,30,50,200,280,true,false,false,false,true,true,false,true,true],
    ['821','Baummarder','Marderartige','Martes','martes',true,400,480,200,260,780,980,true,false,false,false,true,true,false,true,true],
    ['822','Steinmarder','Marderartige','Martes','foina',true,400,560,200,320,740,830,true,false,false,false,true,true,false,true,true]]

annotations_lookup_table.each do |value|
  AnnotationsLookupTable.create(annotation_id: value[0],
                                name: value[1],
                                family: value[2],
                                genus: value[3],
                                species: value[4],
                                selectable: value[5],
                                body_length_min: value[6],
                                body_length_max: value[7],
                                tail_length_min: value[8],
                                tail_length_max: value[9],
                                hindfoot_length_min: value[10],
                                hindfoot_length_max: value[11],
                                tail_hairy: value[12],
                                tail_naked: value[13],
                                face_painting: value[14],
                                bodyshape_compact: value[15],
                                bodyshape_streched: value[16],
                                ears_visible: value[17],
                                ears_hidden: value[18],
                                snout_blunt: value[19],
                                snout_pointy: value[20])
end


case Rails.env
  when 'development'

end