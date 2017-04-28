# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

annotations = [
    ['100',nil,'Bilche',nil,nil,false,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['111','Gartenschläfer','Bilche','Eliomys','quercinus',false,100,170,90,125,220,320,true,false,true,true,false,true,false,true,true],
    ['121','Baumschläfer','Bilche','Dryomys','nitedula',false,80,130,80,95,190,240,true,false,true,true,false,true,false,true,true],
    ['131','Siebenschläfer','Bilche','Glis','glis',false,130,190,110,150,240,340,true,false,true,true,false,true,false,true,true],
    ['141','Haselmaus','Bilche','Muscardinus','avellanarius',false,60,90,55,75,150,185,true,false,false,true,false,true,false,true,true],
    [nil,nil,'Langschwanzmäuse',nil,nil,false,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,'Rattus',nil,false,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['211','Hausratte','Langschwanzmäuse','Rattus','rattus',true,140,230,170,280,300,400,false,true,false,true,false,true,false,true,true],
    ['212','Wanderratte','Langschwanzmäuse','Rattus','norvegicus',true,190,270,160,229,380,450,false,true,false,true,false,true,false,true,true],
    ['221','Zwergmaus','Langschwanzmäuse','Micromys','minutus',false,58,76,51,72,130,160,false,true,false,true,false,true,false,true,true],
    [nil,nil,nil,'Apodemus',nil,false,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['231','Gelbhalsmaus','Langschwanzmäuse','Apodemus','flavicollis',true,88,130,92,134,230,270,false,true,false,true,false,true,false,true,true],
    ['232','Waldmaus','Langschwanzmäuse','Apodemus','sylvaticus',true,77,110,69,115,200,250,false,true,false,true,false,true,false,true,true],
    ['233','Alpenwaldmaus','Langschwanzmäuse','Apodemus','alpicola',true,86,96,110,120,0,0,false,true,false,true,false,true,false,true,true],
    ['241','Hausmaus','Langschwanzmäuse','Mus','domesticus',false,75,103,72,102,165,195,false,true,false,true,false,true,false,true,false],
    [nil,nil,'Wühlmäuse',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['311','Schermaus','Wühlmäuse','Arvicola','terrestris',false,120,170,50,75,220,250,false,true,false,true,false,false,true,true,false],
    ['321','Rötelmaus','Wühlmäuse','Clethrionomys','glareolus',false,85,110,50,70,150,200,false,true,false,true,false,true,true,true,false],
    ['331','Schneemaus','Wühlmäuse','Chionomys','nivalis',false,100,130,56,76,185,220,false,true,false,true,false,true,true,true,false],
    [nil,nil,nil,'Microtus',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['341','Feldmaus','Wühlmäuse','Microtus','arvalis',true,90,120,24,45,150,185,false,true,false,true,false,false,true,true,false],
    ['342','Erdmaus','Wühlmäuse','Microtus','agrestis',true,95,133,35,46,160,205,false,true,false,true,false,false,true,true,false],
    [nil,nil,nil,'Microtus (Pitmys)',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['351','Fatio - Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','multiplex',true,90,110,40,44,150,160,false,true,false,true,false,false,true,true,false],
    ['352','Savi - Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','savii',true,90,100,22,30,130,150,false,true,false,true,false,false,true,true,false],
    ['353','Kleinwühlmaus','Wühlmäuse','Microtus (Pitmys)','subterraneus',true,70,100,35,42,140,145,false,true,false,true,false,false,true,true,false],
    [nil,nil,'Hörnchen',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['411','Eichhörnchen','Hörnchen','Sciurus','vulgaris',false,200,250,150,200,520,620,true,false,false,false,true,true,false,true,false],
    [nil,nil,'Spitzmäuse',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['511','Feldspitzmaus','Spitzmäuse','Crocidura','leucodon',false,64,84,29,41,110,140,false,true,false,true,false,false,true,false,true],
    ['512','Gartenspitzmaus','Spitzmäuse','Crocidura','suaveolens',false,55,77,33,40,100,120,false,true,false,true,false,false,true,false,true],
    ['513','Hausspitzmaus','Spitzmäuse','Crocidura','russula',false,64,84,33,46,110,140,false,true,false,true,false,false,true,false,true],
    ['521','Wasserspitzmaus','Spitzmäuse','Neomys','fodiens',false,72,96,47,77,160,200,false,true,false,true,false,false,true,false,true],
    ['522','Sumpfspitzmaus','Spitzmäuse','Neomys','anomalus',false,64,88,42,64,140,170,false,true,false,true,false,false,true,false,true],
    [nil,nil,nil,'Sorex',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['531','Waldspitzmaus','Spitzmäuse','Sorex','araneus',true,66,88,30,57,100,145,false,true,false,true,false,false,true,false,true],
    ['532','Walliserspitzmaus','Spitzmäuse','Sorex','antinorii',true,54,82,40,60,'NA','NA',false,true,false,true,false,false,true,false,true],
    ['533','Alpenspitzmaus','Spitzmäuse','Sorex','alpinus',true,62,87,60,76,140,160,false,true,false,true,false,false,true,false,true],
    ['534','Zwergspitzmaus','Spitzmäuse','Sorex','minutus',true,44,62,37,46,90,120,false,true,false,true,false,false,true,false,true],
    [nil,nil,'Igel',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['611','Westigel','Igel','Erinaceus','europaeus',false,250,300,25,30,400,470,true,true,false,true,false,false,true,false,true],
    [nil,nil,'Maulwürfe',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,'Talpa',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['711','Blindmaulwurf','Maulwürfe','Talpa','caeca',true,106,123,27,39,160,180,true,true,false,true,false,false,true,false,true],
    ['712','Europäischer Maulwurf','Maulwürfe','Talpa','europaea',true,124,144,27,38,165,200,true,true,false,true,false,false,true,false,true],
    [nil,nil,'Marderartige',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
    ['811','Iltis','Marderartige','Mustela','putorius',false,280,450,100,170,470,700,true,false,true,false,true,true,false,true,true],
    ['812','Hermelin','Marderartige','Mustela','herminea',false,210,370,70,130,330,500,true,false,false,false,true,true,false,true,true],
    ['813','Mauswiesel','Marderartige','Mustela','nivalis',false,140,190,30,50,200,280,true,false,false,false,true,true,false,true,true],
    ['821','Baummarder','Marderartige','Martes','martes',false,400,480,200,260,780,980,true,false,false,false,true,true,false,true,true],
    ['822','Steinmarder','Marderartige','Martes','foina',false,400,560,200,320,740,830,true,false,false,false,true,true,false,true,true]]

annotations.each do |value|
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
