//
//  CoreDataManager.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 04.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//


#import "CoreDataManager.h"
#import "YSEntity+CoreDataClass.h"
#import "YSEntity+CoreDataProperties.h"
#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"
#import "YSPractice+CoreDataClass.h"
#import "YSPractice+CoreDataProperties.h"
#import "YSTeacher+CoreDataClass.h"
#import "YSTeacher+CoreDataProperties.h"
#import "YSStudent+CoreDataClass.h"
#import "YSStudent+CoreDataProperties.h"


//  Названия практик
static NSString * practiceNames[] = {
    @"Виньяса-Флоу", @"Динамическая йога", @"Пилатес", @"Йога для беременных", @"Тай Чи", @"Krama Vinyasa", @"Айенгар Йога",
    @"Аштанга-Виньяса-Йога", @"Yogic Arts", @"Йога в обед", @"5 Ритуалов Тибетских Монахов", @"Детокс Виньяса Йога", @"Йогатерапия", @"Лечебная йога",
    @"Йога в воздухе", @"Акро-Йога", @"Кундалини-Йoга", @"Хатха-Йога"
};

//  Имена преподавателей
static NSString * teacherNames[] = {
    @"Наталья Шидловская", @"Юля Пронина", @"Наталья Поспелова", @"Елена Аккуратова", @"Татьяна Писемская",
    @"Татьяна Скворцова", @"Виталина Семенюк", @"Наталья Тулякова", @"Мария Смирнова", @"Александр Соколов",
    @"Дмитрий Край"
};

//  Набор имен для рандомных студентов
static NSString * studentFirstName[] = {
    @"Алексей", @"Андрей", @"Виталий", @"Владимир", @"Дмитрий",
    @"Егор", @"Игорь", @"Константин", @"Николай", @"Сергей",
    @"Алена", @"Вера", @"Елена", @"Ирина", @"Марина",
    @"Наталья", @"Ольга", @"Светлана", @"Татьяна", @"Ульяна"
};

//  Набор фамилий для рандомных студентов
static NSString * studentLastName[] = {
    @"Аксенов", @"Беляков", @"Володин", @"Грачев", @"Добронравов",
    @"Замков", @"Исташев", @"Иванов", @"Кленов", @"Леонидов",
    @"Медведев", @"Новиков", @"Осташов", @"Петров", @"Пугачев",
    @"Рощин", @"Сидоров", @"Старков", @"Тарков", @"Шпаков"
};



@implementation CoreDataManager

#pragma mark - Singleton
//  Синглтон
+ (CoreDataManager *) sharedManager {
    static CoreDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    return manager;
}

#pragma mark - CoreDataSavingSupport
- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


@synthesize persistentContainer = _persistentContainer;
- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"YOGA_Studios"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}

#pragma mark - ControlEntitys
- (void) setEntitysWithName:(NSString *)name StudentNamber:(NSInteger)studentNum {
    NSLog(@"SET");
    
    //  Создаем студию
    YSStudio * studio = [self createStudioWithName:name];
    
    
    //  Создаем всех учителей
    NSArray * arrayTeacher = [self createAllTeacher];
    for (YSTeacher * teacher in arrayTeacher) {
        teacher.studio = studio;
    }
    
    
    //  Создаем все практики
    NSArray * arrayPractice = [self createAllPractice];
    for (YSPractice * practice in arrayPractice) {
        [practice addStudiosObject:studio];
        
        NSInteger teacherNum = arc4random()%2+1;
        while (practice.teachers.allObjects.count < teacherNum) {
            YSTeacher * teacher = [arrayTeacher objectAtIndex:arc4random()%arrayTeacher.count];
            if (![practice.teachers.allObjects containsObject:teacher] | (teacher.practices.allObjects.count > 3)) {
                [practice addTeachersObject:teacher];
            }
        }
    }
    
    
    //  Создаем студентов
    for (int i = 0; i < studentNum; i++) {
        YSStudent * student = [self createRandomStudent];
        student.studio = studio;
        NSInteger practicesNum = arc4random()%3 + 1;
        while (student.practices.allObjects.count < practicesNum) {
            YSPractice * practice = [arrayPractice objectAtIndex:arc4random()%arrayPractice.count];
            if (![student.practices.allObjects containsObject:practice]) {
                [student addPracticesObject:practice];
            }
        }
    }
    
    
    //  Проверяем практики на наличие студентов, если нет то и практики эти не нужны
    for (YSPractice * practice in studio.practices.allObjects) {
        if (practice.students.allObjects.count < 2 | practice.teachers.allObjects.count == 0) {
            NSLog(@"удалить эту практику TIC = %li STU = %li", practice.teachers.allObjects.count, practice.students.allObjects.count);
            [self.persistentContainer.viewContext deleteObject:practice];
        } else {
            NSLog(@"не удалять");
        }
    }
    
    
    [self saveContext];
}


//  Вывод в консоль всех сущностей
- (void) printEntitys {
    NSArray * array = [self.persistentContainer.viewContext executeFetchRequest:[YSEntity fetchRequest]
                                                                          error:nil];
    for (id entity in array) {
        if ([entity isKindOfClass:[YSStudio class]]) {
            NSLog(@"STUDIO");
        } else if ([entity isKindOfClass:[YSPractice class]]) {
            NSLog(@"PRACTICE");
        } else if ([entity isKindOfClass:[YSTeacher class]]) {
            NSLog(@"TEACHER");
        } else if ([entity isKindOfClass:[YSStudent class]]) {
            NSLog(@"STUDENT");
        }
    }
}

//  Очистка кор даты
- (void) clearEntitys {
    NSError * error = nil;
    NSArray * array = [self.persistentContainer.viewContext executeFetchRequest:[YSEntity fetchRequest]
                                                                          error:&error];
    for (YSEntity * entity in array) {
        [self.persistentContainer.viewContext deleteObject:entity];
    }
    [self saveContext];
}


#pragma mark - CreateEntitys
//  Создание студии по имени
- (YSStudio *) createStudioWithName:(NSString *)name {
    YSStudio * studio = [NSEntityDescription insertNewObjectForEntityForName:@"YSStudio"
                                                      inManagedObjectContext:self.persistentContainer.viewContext];
    studio.name = name;
    return  studio;
}


//  Создание рандомной практики
- (YSPractice *) createRandomPractice {
    YSPractice * practice = [NSEntityDescription insertNewObjectForEntityForName:@"YSPractice"
                                                          inManagedObjectContext:self.persistentContainer.viewContext];
    practice.name = practiceNames[arc4random()%18];
    return practice;
}


//  Создание рандомного учителя
- (YSTeacher *) createRandomTeacher {
    YSTeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"YSTeacher"
                                                        inManagedObjectContext:self.persistentContainer.viewContext];
    NSInteger teach = arc4random()%11;
    NSArray * name = [teacherNames[teach] componentsSeparatedByString:@" "];
    teacher.firstName = [name firstObject];
    teacher.lastName = [name lastObject];
    teacher.age = arc4random()%15 + 20;
    return teacher;
}


//  Создание рандомного студента
- (YSStudent *) createRandomStudent {
    YSStudent * student = [NSEntityDescription insertNewObjectForEntityForName:@"YSStudent"
                                                        inManagedObjectContext:self.persistentContainer.viewContext];
    NSInteger studFN = arc4random()%20;
    NSInteger studLN = arc4random()%20;
    student.firstName = studentFirstName[studFN];
    if (studFN > 9) {
        student.lastName = [NSString stringWithFormat:@"%@а", studentLastName[studLN]];
        student.sex = 0;
    } else {
        student.lastName = studentLastName[studLN];
        student.sex = 1;
    }
    student.age = arc4random()%30 + 12;
    return student;
}


//  Создание всех практик
- (NSArray *) createAllPractice {
    NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i = 0; i < 18; i++) {
            YSPractice * practice = [NSEntityDescription insertNewObjectForEntityForName:@"YSPractice"
                                                              inManagedObjectContext:self.persistentContainer.viewContext];
            practice.name = practiceNames[i];
            practice.descriptionText = [self descriptionWithName:practice.name]; 
            [array addObject:practice];
            }
    return array;
}


//  Создание всех учителей
- (NSArray *) createAllTeacher {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 11; i++) {
        YSTeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"YSTeacher"
                                                            inManagedObjectContext:self.persistentContainer.viewContext];
        NSString * name = teacherNames[i];
        NSArray * nameArray = [name componentsSeparatedByString:@" "];
        teacher.firstName = [nameArray firstObject];
        teacher.lastName = [nameArray lastObject];
        teacher.age = arc4random()%15+20;
        
        if (i < 9) {
            teacher.sex = 0;
        } else {
            teacher.sex = 1;
        }
        
        [array addObject:teacher];
    }
    return array;
}


//  Создание студента из имени, студии, практики
- (void) addStudentWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice {
    
    YSStudent * student = [NSEntityDescription insertNewObjectForEntityForName:@"YSStudent"
                                                        inManagedObjectContext:self.persistentContainer.viewContext];
    student.firstName = firstName;
    student.lastName = lastName;
    student.studio = studio;
    student.sex =NSNotFound;
    
    if (practice) {
        [student addPracticesObject:practice];
    }
    
    [self saveContext];
}

//  Создание преподавателя из имени, студии, практики
- (void) addTeacherWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice {
    
    YSTeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"YSTeacher"
                                                        inManagedObjectContext:self.persistentContainer.viewContext];
    teacher.firstName = firstName;
    teacher.lastName = lastName;
    teacher.studio = studio;
    teacher.sex = NSNotFound;
    
    if (practice) {
        [teacher addPracticesObject:practice];
    }
    
    [self saveContext];
}


//  Создание практики из имени, студии
- (void) addPracticeWithName:(NSString *)name Studio:(YSStudio *)studio {
    
    YSPractice * practice = [NSEntityDescription insertNewObjectForEntityForName:@"YSPractice" inManagedObjectContext:self.persistentContainer.viewContext];
    
    practice.name = name;
    practice.descriptionText = [self descriptionWithName:name];
    practice.imageName = @"imageNotFound";
    
    [practice addStudiosObject:studio];
    
    [self saveContext];
}


//  Описание по имени практики
- (NSString *) descriptionWithName:(NSString *)name {
    NSString * description = nil;
    if ([name isEqualToString: @"Виньяса-Флоу"]) {
        description = @"Движение – это естественно, именно оно приводит к развитию на всех уровнях. Жизнь – это движение, а движение – это жизнь.ВИНЬЯСА-ФЛОУ ЙОГА – естественное движение в йога-потоке… Подобно медитации в движении практика виньяса йоги способствует более глубокому, медитативному погружению в поток меняющихся положений тела, позволяют работать с телом, минуя суету ума.  В основе – естественное движение, умение подстроиться под вечно меняющиеся обстоятельства и быстро реагировать на них. ВИНЬЯСА-ФЛОУ ЙОГА – импульс к действию… как на коврике так и в жизни! Это легкость, динамика, вдохновение и драйв! В этих занятиях нет «запредельных» асан и долгих статичных форм, положение тела все время меняется в едином йога-потоке. ВИНЬЯСА-ФЛОУ ЙОГА – союз статики и динамики… Это целостный подход, стремление к получению личного опыта и достижений собственных целей! ";
    } else if ([name isEqualToString: @"Динамическая йога" ]) {
        description = @"Йога, способствующая похудению, укреплению и растягиванию мышц всего тела. Она, как профессиональный скульптор, формирует идеальный силуэт, убирая лишние килограммы. Занятия динамической йогой принесут пользу не только Вашей фигуре, но и здоровью. Они заряжают энергией и хорошим настроением. ";
    } else if ([name isEqualToString: @"Пилатес"]) {
        description = @"Система, которая включает в себя упражнения для всех частей тела и делает упор на взаимодействии разума и тела при выполнении упражнений. Выполнение упражнений пилатеса сопровождается концентрацией на дыхательном ритме, правильности выполнения упражнения и осознанием действия каждого упражнения на ту или иную группу мышц. Пилатес укрепляет мышцы пресса, улучшает баланс и координацию, а также снижает стресс, способствует потере веса. Упражнения пилатеса безопасны и подходят для широкого возрастного спектра.";
    } else if ([name isEqualToString: @"Йога для беременных"]) {
        description = @"Это физическая и психологическая подготовка к родам. Занятие длится 1,5 часа: 1 час упражнений и 30 минут дыхательных практик. Результатом становятся улучшенное самочувствие как матери, так и малыша во время вынашивания, легкие роды и быстрое послеродовое восстановление. Дыхательные практики помогут уменьшить боль во время схваток, усилят или, при необходимости, задержат потуги, научат правильно расслабляться для успешного течения родов.";
    } else if ([name isEqualToString: @"Тай Чи"]) {
        description = @"Это древний метод снятия усталости, связанный с контролированием энергии Чи (Ци), которая циркулирует в нашем теле. Представляет собой движения плавные и неторопливые, поэтому занятия подходят и для людей пожилого возраста. За счет глубины дыхания нормализуется кровообращение, укрепляются и становятся эластичнее стенки сосудов. Тай Чи иногда называют перемещением в медитацию. Укрепляет и лечит душу, тело и психику, целенаправленно и благотворно влияет на физическое состояние человека.";
    } else if ([name isEqualToString: @"Krama Vinyasa"]) {
        description = @"Древняя система йоги, возрожденная йогом Шри Кришнамачария. Основана на динамичном и оптимальном переходе из одной позы в другую и синхронизирована с дыханием.";
    } else if ([name isEqualToString: @"Айенгар Йога"]) {
        description = @"Разновидность Хатха Йоги, основанная  йогином Айенгаром. Айенгар-йога основное внимание уделяет правильному положению тела, характерной особенностью метода является статичное выполнение асан с необходимыми опорами. Айенгар-Йога может быть также использована в лечебных целях.";
    } else if ([name isEqualToString: @"Аштанга-Виньяса-Йога"]) {
        description = @"Динамическая практика йоги. Основателем этой школы является Паттаби Джойс, возглавлявший Институт йоги в Майсуре, Индия. Согласно Джойсу, практикующий должен развить себя до соответствия идеалам йоги. Аштанга-Виньяса включает в себя последовательности асан, связанных между собой комплексами движений (виньясами)  и выполняемых совместно с пранаямой, бандхами и дришти. ";
    } else if ([name isEqualToString: @"Yogic Arts"]) {
        description = @"Удивительная комбинация йоги и боевых искусств, уходящая корнями в Корейское Кунг-Фу, Тайский массаж и Аштангу-Йога, созданная Мастером Данкон Вонгом.";
    } else if ([name isEqualToString: @"Йога в обед"]) {
        description = @"Для занятых людей, позволяет физически восстановиться и ослабить напряжение и психологическое давление, свойственное современному образу жизни.";
    } else if ([name isEqualToString: @"5 Ритуалов Тибетских Монахов"]) {
        description = @"Уникальный комлекс тибетских лам, стимулирующий циркуляцию полноценной энергии через чакры и вдыхающий необходимую жизненную силу в соответствующие органы, железы и нервы. Пять тибетцев также укрепляют и тонизируют основные группы мышц, дают быстро и хорошо восстанавливаемую физическую форму. Систематическое выполнение этих упражнений позволит восстановить здоровье, сбросить лишний вес, улучшить потенцию.";
    } else if ([name isEqualToString: @"Детокс Виньяса Йога"]) {
        description = @"Очищение организма с помощью дыхательных техник. Класс включает в себя несколько дыхательных циклов с задержками дыхания, комплекс Виньяс в чередовании со статикой в скрутках. Все упражнения способствуют активизации очистительных процессов в организме.";
    } else if ([name isEqualToString: @"Йогатерапия"]) {
        description = @"Это лечение и профилактика заболеваний позвоночника и суставов средствами йоги. Йогатерапия позволяет справиться с болями в спине, нарушением осанки, межпозвоночными грыжами и протрузиями. Со временем позвоночник приобретает необходимый тонус, что позволяет равномернее распределять нагрузку, избавиться от болей, вызванных разными причинами, улучшить осанку. Косвенный эффект – улучшение общего самочувствия. Общеоздоравливающий эффект распространяется на все системы организма, так как улучшается кровоснабжение всех внутренних органов, восстанавливаются процессы эндокринной системы, органов пищеварения, повышается иммунитет и улучшается психоэмоциональное состояние. Занятия по йогатерапии не имеют возрастных ограничений. На такое занятие может прийти любой человек, независимо от уровни его физической подготовки. Но особенно полезной йогатерапия будет детям, у которых только формируется осанка, а также людям старше 40 лет, поскольку именно этот возраст наиболее опасен для позвоночника. Представляет собой специальные программы, основанные на принципах Хатха-Йоги, позволяющие избавить ученика от дискомфорта в спине, шее и пояснице, растянуть мышцы и сухожилия, повысить подвижность суставов, доставить ощущение хорошей мышечной работы и восстановить правильную работу скелето-мышечного аппарата, а в совокупности с изменением диеты способна на клеточном уровне преодолеть недуги.";
    } else if ([name isEqualToString: @"Лечебная йога"]) {
        description = @"Возраст студентов от детского до старческого. Данная методика устраняет сложнейшие формы патологии такие, как секвестрированная грыжа, различные формы протрузий дисков, радикулопатии, люмбаго, дискогенные радикулиты, а также последствия травм, при которых медицина безсильна либо предлагает только хирургическое вмешательство. Работа направлена на устранение изначальных причин заболеваний через практику йога-терапии, а не на уровне снятия симптомов. Наш организм – это саморегулирующаяся и самовосстанавливающаяся система. Упорная и регулярная практика данного метода позволит  полностью вернуть утраченную двигательую активность позвоночника, а значит и восстановить утраченную гибкость и здоровье. Даже при дистрофических и дегенеративных возрастных изменениях каждый способен восстановить утраченную форму и прогрессировать к улучшению работоспособности суставов, связок и мышц.";
    } else if ([name isEqualToString: @"Йога в воздухе"]) {
        description = @"Уникальное сочетание асан йоги, лечебной гимнастики, спонтанного движения с имитацией полета, релаксационных и медитативных поз в гамаке. Занятия в гамаке позволяют снизить нагрузку на позвоночник, растянуть его. Йога в воздухе освобождает тело от напряжений, растягивает мышцы и сухожилия, повышает подвижность суставов, доставляет радость и ощущение хорошей мышечной работы. Такое направление хотя и не является йогой в привычном и строгом смысле слова, но интересно своими йогатерапевтическими возможностями.";
    } else if ([name isEqualToString: @"Акро-Йога"]) {
        description = @"Это телесная практика, которая объединяет в себе элементы йоги, акробатики и целительского искусства. Эти три древние дисциплины составляют основу новой практики, которая направлена на развитие доверия и согласованности, а также творческих и игровых моментов между партнерами. Быть «в моменте» и в балансе с другим человеком – это суть Акро-Йоги.";
    } else if ([name isEqualToString: @"Кундалини-Йoга"]) {
        description = @"Одно из направлений современной йоги, система упражнений, призванная заставить энергию кундалини  подниматься из основания позвоночника. Она должна поэтапно пройти по всем последующим чакрам вплоть до высшей – сахасрары. Наиболее известное пособие по Кундалини-Йоге – «Прапанчасара-Тантра» – о сущности миросоздания, в которой нижняя чакра отождествляется с вместилищем Брахмана в виде Лингама, вокруг которого и свертывается женская «змееобразная энергия» кундалини, принуждаемая затем к восхождению в высший центр посредством садханы(так в  индуизме и буддизме назывют духовную практику), в результате чего наступает «освобождение». Для Западного мира Кундалини-Йогу открыл Йоги Бхаджан, в 1968 году основавший в СШАблаготворительный фонд «Здоровые, Счастливые, Благословенные» – организацию, обучающую йоге.";
    } else if ([name isEqualToString: @"Хатха-Йога"]) {
        description = @"Направление йоги, систематизированное Свами Сватмарамой  (автором трактата «Хатха Йога Прадипика») в XV веке. Хатха-Йога представляется системой подготовки физического тела для сложных медитаций. Это учение о физической гармонии, достигаемой с помощью физических (диета, дыхание, асаны,бандхи, мудры) и психических (медитация и концентрация внимания во время выполнения асан, пранаямы) средств воздействия на организм. Болезни, как считают йоги, – это неправильное распределение жизненной энергии, праны, в организме; и выполнение определённых асан, а также выполнение пранаямы ведёт к правильному перераспределению праны в организме, что и излечивает болезни, как физического плана, так и психического. Хатха-Йога помогает обрести полноценное здоровье, задействовав скрытые резервы собственного организма, и своими силами, своей волей добиться исцеления.";
    }
    return description;
}



@end
