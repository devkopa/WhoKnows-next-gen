import { PrismaClient } from '@prisma/client';


const prisma = new PrismaClient();


export const userRepository = {

    async getUserId(usernameReq) {
        return await prisma.users.findUnique({
                where: {
                    username: usernameReq
                },
                select: {
                    id: true
                }
            })
    }

}