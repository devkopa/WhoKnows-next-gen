import { PrismaClient } from '@prisma/client';


const prisma = new PrismaClient();


export const pagesRepository = {

    async findBySearch(searchString, language) {
        return await prisma.pages.findMany({
            where: {
                language: {
                    contains: language
                },
                content : {
                    contains: searchString
                }
            }
        })
    }

}